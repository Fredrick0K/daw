#!/bin/bash
# Comprueba el sitio público, la API, la redirección HTTPS y avisos en los puertos locales DAW2XX.
echo "Iniciando batería de pruebas..."

# 1. Comprobar que la web pública devuelve 200 OK
curl -s -o /dev/null -w "Prueba 1 (Web Publica): %{http_code}\n" -k https://publica.localhost:8443/

# 2. Comprobar error 404
curl -s -o /dev/null -w "Prueba 2 (Error 404): %{http_code}\n" -k https://publica.localhost:8443/ruta-falsa

# 3. Comprobar que /avisos pide contraseña (401 Unauthorized)
curl -s -o /dev/null -w "Prueba 3 (Avisos sin clave): %{http_code}\n" -k https://publica.localhost:8443/avisos/

# 4. Comprobar /avisos con contraseña correcta (200 OK)
curl -s -o /dev/null -w "Prueba 4 (Avisos con clave): %{http_code}\n" -u socio:tu_contraseña -k https://publica.localhost:8443/avisos/

# 5. Comprobar la API
curl -s -o /dev/null -w "Prueba 4 (API animales): %{http_code}\n" -k https://publica.localhost:8443/api/animales

# 6. Comprobar redirección HTTP a HTTPS (301 Moved Permanently)
curl -s -o /dev/null -w "Prueba 5 (Redirección HTTP): %{http_code}\n" http://publica.localhost:8080/

# 7. Comprobar /avisos con credenciales válidas (200 OK)
if [ -n "${SOCIO_USUARIO:-}" ] && [ -n "${SOCIO_PASSWORD:-}" ]; then
	curl -s -o /dev/null -w "Prueba 6 (Avisos con clave): %{http_code}\n" \
		-u "$SOCIO_USUARIO:$SOCIO_PASSWORD" -k https://publica.localhost:8443/avisos/
else
	echo "Prueba 6 (Avisos con clave): omitida; define SOCIO_USUARIO y SOCIO_PASSWORD."
fi