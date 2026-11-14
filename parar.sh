#!/bin/bash
# Para el servidor entero. Desde la carpeta del trabajo:  bash parar.sh

# Matar solo nuestros procesos exactos de Python
kill $(cat api/pid.txt avisos/pid.txt 2> /dev/null) 2> /dev/null
rm -f api/pid.txt avisos/pid.txt

# Detener Nginx
(cd /c/Users/DAW213/daw/nginx-1.28.3 && ./nginx.exe -s stop 2> /dev/null)

sleep 1
echo "Servicios detenidos."