#!/bin/bash
# Arranca el servidor entero. Desde la carpeta del trabajo, en Git Bash: bash arrancar.sh
set -o pipefail  # Propaga errores de comandos dentro de tuberías, como las pruebas enviadas a tee.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Obtiene la carpeta de este script.
NGINX_DIR="$SCRIPT_DIR/nginx-1.28.3"  # Guarda la ruta de Nginx local.

bash "$SCRIPT_DIR/parar.sh"  # Detiene servicios de una ejecución anterior.
cp -r "$SCRIPT_DIR/nginx/sitios" "$NGINX_DIR/"  # Copia los sitios web a Nginx.
cp "$SCRIPT_DIR/nginx/conf/publica.crt" "$NGINX_DIR/conf/publica.crt"  # Copia el certificado HTTPS.
cp "$SCRIPT_DIR/nginx/conf/publica.key" "$NGINX_DIR/conf/publica.key"  # Copia la clave del certificado.
cp "$SCRIPT_DIR/nginx/conf/usuarios.txt" "$NGINX_DIR/conf/usuarios.txt"  # Copia las cuentas de acceso.
cp "$SCRIPT_DIR/nginx/conf/nginx-local.conf" "$NGINX_DIR/conf/nginx.conf"  # Instala la config local de Nginx.

cd "$NGINX_DIR"  # Entra en la carpeta de Nginx.
./nginx.exe -t || exit 1  # Valida la config y termina si hay errores.
./nginx.exe &  # Inicia Nginx en segundo plano.
cd - > /dev/null  # Vuelve a la carpeta anterior sin mostrarla.

# Arrancar API
python "$SCRIPT_DIR/api/app.py" > "$SCRIPT_DIR/logs/api_salida.txt" 2>&1 &  # Inicia la API y guarda su salida.
echo $! > "$SCRIPT_DIR/api/pid.txt"  # Guarda el PID de la API para detenerla después.

# Arrancar Avisos
python "$SCRIPT_DIR/avisos/avisos.py" > "$SCRIPT_DIR/logs/avisos_salida.txt" 2>&1 &  # Inicia el servidor de avisos.
echo $! > "$SCRIPT_DIR/avisos/pid.txt"  # Guarda su PID para detenerlo después.

sleep 3  # Espera a que los servicios terminen de iniciar.
bash "$SCRIPT_DIR/pruebas.sh" | tee "$SCRIPT_DIR/pruebas.txt"  # Ejecuta pruebas y guarda sus resultados.