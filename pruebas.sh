#!/bin/bash
# Prueba el Nginx local, la API y avisos en los puertos del DAW2XX.
set +e

PUBLIC_HTTP="http://publica.localhost:8080"
PUBLIC_HTTPS="https://publica.localhost:8443"
TMP_DIR="$(mktemp -d)"
BODY_FILE="$TMP_DIR/respuesta.txt"
HEADER_FILE="$TMP_DIR/cabeceras.txt"
LARGE_FILE="$TMP_DIR/grande.txt"
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT

report() {
	local name="$1"
	local expected="$2"
	local actual="$3"
	TOTAL=$((TOTAL + 1))
	if [ "$actual" = "$expected" ]; then
		PASSED=$((PASSED + 1))
		printf 'OK      %02d - %s (%s)\n' "$TOTAL" "$name" "$actual"
	else
		FAILED=$((FAILED + 1))
		printf 'FALLO   %02d - %s: esperado %s, recibido %s\n' "$TOTAL" "$name" "$expected" "$actual"
	fi
}

skip_test() {
	TOTAL=$((TOTAL + 1))
	SKIPPED=$((SKIPPED + 1))
	printf 'OMITIDA %02d - %s\n' "$TOTAL" "$1"
}

check_status() {
	local name="$1"
	local expected="$2"
	shift 2
	local actual
	actual="$(curl -sS --noproxy '*' --connect-timeout 1 --max-time 2 "$@" -o "$BODY_FILE" -w '%{http_code}' 2>/dev/null || true)"
	[ -n "$actual" ] || actual="000"
	report "$name" "$expected" "$actual"
}

check_body() {
	local name="$1"
	local text="$2"
	if grep -Fq "$text" "$BODY_FILE"; then
		report "$name" presente presente
	else
		report "$name" presente ausente
	fi
}

check_header() {
	local name="$1"
	local header_pattern="$2"
	curl -sS --noproxy '*' --connect-timeout 1 --max-time 2 -k --resolve publica.localhost:8443:127.0.0.1 \
		-D "$HEADER_FILE" -o /dev/null "$PUBLIC_HTTPS/" 2>/dev/null || true
	if grep -Eiq "$header_pattern" "$HEADER_FILE"; then
		report "$name" presente presente
	else
		report "$name" presente ausente
	fi
}

echo "Iniciando batería de pruebas..."

# Sitio público: redirecciones, páginas, CSS y página de error personalizada.
check_status "HTTP redirige a HTTPS" 301 --resolve publica.localhost:8080:127.0.0.1 "$PUBLIC_HTTP/"
check_status "Portada pública" 200 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/"
check_status "Página de contacto" 200 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/contacto.html"
check_status "Página quiénes somos" 200 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/quienesSomos.html"
check_status "Hoja de estilos CSS" 200 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/estilo.css"
check_status "Ruta inexistente devuelve 404" 404 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/ruta-inexistente-pruebas.html"
check_body "404 usa la página personalizada" "Te has salido del camino"

# Cabeceras de seguridad, compresión y ocultación de versión.
check_header "Cabecera HSTS" '^Strict-Transport-Security:'
check_header "Cabecera X-Content-Type-Options" '^X-Content-Type-Options:[[:space:]]*nosniff'
check_header "Cabecera X-Frame-Options" '^X-Frame-Options:[[:space:]]*SAMEORIGIN'
curl -sS --noproxy '*' --connect-timeout 1 --max-time 2 -k --resolve publica.localhost:8443:127.0.0.1 -H 'Accept-Encoding: gzip' \
	-D "$HEADER_FILE" -o "$BODY_FILE" "$PUBLIC_HTTPS/" 2>/dev/null || true
if grep -Eiq '^Content-Encoding:[[:space:]]*gzip' "$HEADER_FILE"; then
	report "Respuesta comprimida con gzip" gzip gzip
else
	report "Respuesta comprimida con gzip" gzip sin-gzip
fi
curl -sS --noproxy '*' --connect-timeout 1 --max-time 2 -k --resolve publica.localhost:8443:127.0.0.1 \
	-D "$HEADER_FILE" -o /dev/null "$PUBLIC_HTTPS/" 2>/dev/null || true
if grep -Eiq '^Server:[[:space:]]*nginx/[0-9]' "$HEADER_FILE"; then
	report "Server no revela versión de Nginx" oculta expuesta
else
	report "Server no revela versión de Nginx" oculta oculta
fi

# Zona socios: los accesos sin credenciales o con clave errónea deben rechazarse.
check_status "Socios sin credenciales" 401 -k --resolve publica.localhost:8443:127.0.0.1 "$PUBLIC_HTTPS/socios/"
check_status "Socios con clave incorrecta" 401 -k --resolve publica.localhost:8443:127.0.0.1 \
	-u ana:clave_incorrecta "$PUBLIC_HTTPS/socios/"
if [ -n "${SOCIO_USUARIO:-}" ] && [ -n "${SOCIO_PASSWORD:-}" ]; then
	check_status "Socios con credenciales válidas" 200 -k --resolve publica.localhost:8443:127.0.0.1 \
		-u "$SOCIO_USUARIO:$SOCIO_PASSWORD" "$PUBLIC_HTTPS/socios/"
else
	skip_test "Socios con credenciales válidas; define SOCIO_USUARIO y SOCIO_PASSWORD."
fi

# Sitio de descargas: su index.html muestra los documentos disponibles.
check_status "Portada de descargas" 200 --resolve descargas.localhost:8080:127.0.0.1 \
	"http://descargas.localhost:8080/"
check_body "Descargas muestra documentos" "Documentos para descargar"
check_status "Fichero descargable" 200 --resolve descargas.localhost:8080:127.0.0.1 \
	"http://descargas.localhost:8080/FichaAdopcion.txt"
check_status "Host desconocido se cierra (444)" 000 --resolve desconocido.localhost:8080:127.0.0.1 \
	"http://desconocido.localhost:8080/"

# API detrás de Nginx.
check_status "Lista de animales por Nginx" 200 -k --resolve publica.localhost:8443:127.0.0.1 \
	"$PUBLIC_HTTPS/api/animales"
check_status "Animal existente por Nginx" 200 -k --resolve publica.localhost:8443:127.0.0.1 \
	"$PUBLIC_HTTPS/api/animales/1"
check_status "Animal inexistente por Nginx" 404 -k --resolve publica.localhost:8443:127.0.0.1 \
	"$PUBLIC_HTTPS/api/animales/9999"
printf '%2000s' '' | tr ' ' 'A' > "$LARGE_FILE"
check_status "API rechaza cuerpo de más de 1 KB" 413 -k --resolve publica.localhost:8443:127.0.0.1 \
	--data-binary "@$LARGE_FILE" "$PUBLIC_HTTPS/api/animales"

# Servicio de avisos directo y a través de la zona protegida del sitio.
check_status "Lista de avisos directa" 200 http://127.0.0.1:8001/avisos
check_status "Publicar aviso directo" 201 -d 'Aviso de prueba directa' http://127.0.0.1:8001/avisos
check_status "Ruta directa de avisos inexistente" 404 http://127.0.0.1:8001/ruta-inexistente
check_status "Avisos web sin credenciales" 401 -k --resolve publica.localhost:8443:127.0.0.1 \
	"$PUBLIC_HTTPS/avisos"
if [ -n "${SOCIO_USUARIO:-}" ] && [ -n "${SOCIO_PASSWORD:-}" ]; then
	check_status "Lista de avisos web autenticada" 200 -k --resolve publica.localhost:8443:127.0.0.1 \
		-u "$SOCIO_USUARIO:$SOCIO_PASSWORD" "$PUBLIC_HTTPS/avisos"
	check_status "Publicar aviso web autenticado" 201 -k --resolve publica.localhost:8443:127.0.0.1 \
		-u "$SOCIO_USUARIO:$SOCIO_PASSWORD" -d 'Aviso de prueba web' "$PUBLIC_HTTPS/avisos"
else
	skip_test "Lista de avisos web autenticada; define SOCIO_USUARIO y SOCIO_PASSWORD."
	skip_test "Publicar aviso web autenticado; define SOCIO_USUARIO y SOCIO_PASSWORD."
fi

printf '\nResumen: %s pruebas, %s correctas, %s fallidas, %s omitidas.\n' \
	"$TOTAL" "$PASSED" "$FAILED" "$SKIPPED"
[ "$FAILED" -eq 0 ]