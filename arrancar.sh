#!/bin/bash
# Arranca el entorno local desde Windows/Git Bash, usando rutas relativas al proyecto.
set -o pipefail  # Propaga errores de comandos dentro de tuberías, como las pruebas enviadas a tee.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Obtiene la carpeta de este script.
NGINX_DIR="$SCRIPT_DIR/nginx-1.28.3"  # Guarda la ruta de Nginx local.
PYTHON_CMD=()

if command -v python >/dev/null 2>&1; then
	PYTHON_CMD=(python)
elif command -v python3 >/dev/null 2>&1; then
	PYTHON_CMD=(python3)
elif command -v py >/dev/null 2>&1; then
	PYTHON_CMD=(py -3)
else
	echo "Error: instala Python 3 y asegúrate de que python, python3 o py estén en PATH." >&2
	exit 1
fi

if [ ! -x "$NGINX_DIR/nginx.exe" ]; then
	echo "Error: no se encuentra Nginx para Windows en $NGINX_DIR/nginx.exe." >&2
	exit 1
fi

if [ ! -f "$SCRIPT_DIR/nginx/conf/publica.crt" ] || [ ! -f "$SCRIPT_DIR/nginx/conf/publica.key" ]; then
	echo "Error: faltan nginx/conf/publica.crt o nginx/conf/publica.key." >&2
	echo "Consulta el README para generar certificados locales." >&2
	exit 1
fi

if ! "${PYTHON_CMD[@]}" -c "import flask, waitress" >/dev/null 2>&1; then
	echo "Error: instala las dependencias con '${PYTHON_CMD[*]} -m pip install -r api/requirements.txt'." >&2
	exit 1
fi

mkdir -p "$SCRIPT_DIR/logs" \
	"$NGINX_DIR/temp/client_body_temp" "$NGINX_DIR/temp/proxy_temp" \
	"$NGINX_DIR/temp/fastcgi_temp" "$NGINX_DIR/temp/uwsgi_temp" "$NGINX_DIR/temp/scgi_temp"

bash "$SCRIPT_DIR/parar.sh"  # Detiene servicios de una ejecución anterior.
cp -r "$SCRIPT_DIR/nginx/sitios" "$NGINX_DIR/" || exit 1  # Copia los sitios web a Nginx.
cp "$SCRIPT_DIR/nginx/conf/publica.crt" "$NGINX_DIR/conf/publica.crt" || exit 1  # Copia el certificado HTTPS.
cp "$SCRIPT_DIR/nginx/conf/publica.key" "$NGINX_DIR/conf/publica.key" || exit 1  # Copia la clave del certificado.
cp "$SCRIPT_DIR/nginx/conf/usuarios.txt" "$NGINX_DIR/conf/usuarios.txt" || exit 1  # Copia las cuentas de acceso.
cp "$SCRIPT_DIR/nginx/conf/nginx-local.conf" "$NGINX_DIR/conf/nginx.conf" || exit 1  # Instala la config local de Nginx.

cd "$NGINX_DIR"  # Entra en la carpeta de Nginx.
./nginx.exe -t || exit 1  # Valida la config y termina si hay errores.
./nginx.exe &  # Inicia Nginx en segundo plano.
cd - > /dev/null  # Vuelve a la carpeta anterior sin mostrarla.

# Arrancar API
start_python() {
	cd "$SCRIPT_DIR" || exit 1
	exec "${PYTHON_CMD[@]}" "$@"
}

start_python "$SCRIPT_DIR/api/app.py" > "$SCRIPT_DIR/logs/api_salida.txt" 2>&1 &  # Inicia la API y guarda su salida.
echo $! > "$SCRIPT_DIR/api/pid.txt"  # Guarda el PID de la API para detenerla después.

# Arrancar Avisos
start_python "$SCRIPT_DIR/avisos/avisos.py" > "$SCRIPT_DIR/logs/avisos_salida.txt" 2>&1 &  # Inicia el servidor de avisos.
echo $! > "$SCRIPT_DIR/avisos/pid.txt"  # Guarda su PID para detenerlo después.

sleep 3  # Espera a que los servicios terminen de iniciar.
bash "$SCRIPT_DIR/pruebas.sh" | tee "$SCRIPT_DIR/pruebas.txt"  # Ejecuta pruebas y guarda sus resultados.