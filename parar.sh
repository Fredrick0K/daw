#!/bin/bash
# Para el servidor entero. Desde la carpeta del trabajo: bash parar.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_DIR="$SCRIPT_DIR/nginx-1.28.3"

# Matar solo nuestros procesos exactos de Python
if [ -f "$SCRIPT_DIR/api/pid.txt" ]; then
    kill "$(cat "$SCRIPT_DIR/api/pid.txt")" 2> /dev/null
fi
if [ -f "$SCRIPT_DIR/avisos/pid.txt" ]; then
    kill "$(cat "$SCRIPT_DIR/avisos/pid.txt")" 2> /dev/null
fi
rm -f "$SCRIPT_DIR/api/pid.txt" "$SCRIPT_DIR/avisos/pid.txt"

# Detener Nginx
if [ -f "$NGINX_DIR/nginx.exe" ]; then
    (cd "$NGINX_DIR" && ./nginx.exe -s stop 2> /dev/null)
fi

sleep 1
echo "Servicios detenidos."