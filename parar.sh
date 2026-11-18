#!/bin/bash
# Detiene el entorno local usando rutas relativas a la ubicación de este script.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_DIR="$SCRIPT_DIR/nginx-1.28.3"

stop_process() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid
        pid="$(<"$pid_file")"
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
}

# Detiene únicamente los procesos cuyos PID guardó el script de arranque.
stop_process "$SCRIPT_DIR/api/pid.txt"
stop_process "$SCRIPT_DIR/avisos/pid.txt"

# Detener Nginx
if [ -x "$NGINX_DIR/nginx.exe" ]; then
    (cd "$NGINX_DIR" && ./nginx.exe -s stop 2> /dev/null)
fi

sleep 1
echo "Servicios detenidos."