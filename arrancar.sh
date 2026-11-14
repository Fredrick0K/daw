#!/bin/bash
# Arranca el servidor entero. Desde la carpeta del trabajo, en Git Bash:  bash arrancar.sh

bash parar.sh                                   # lo que estuviera arrancado, parado
cp -r nginx/conf nginx/sitios /c/Users/DAW213/daw/nginx-1.28.3/     # la configuracion y los sitios, a nginx

cd /c/Users/DAW213/daw/nginx-1.28.3
./nginx.exe -t || exit 1
./nginx.exe &
cd - > /dev/null

# Arrancar API (asegúrate de que tu archivo se llama app.py o cámbialo aquí)
python api/app.py > logs/api_salida.txt 2>&1 &
echo $! > api/pid.txt

# Arrancar Avisos
python avisos/avisos.py > logs/avisos_salida.txt 2>&1 &
echo $! > avisos/pid.txt

sleep 3
bash pruebas.sh | tee pruebas.txt