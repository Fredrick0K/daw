###

> [!caution]
>
> ### No subir nada al main, todo a tu rama correspondiente. Cualquir commit puede causar conflictos en futuros merge.
>
> Los nuevos cambios en las ramas se hara merge a la base para que todos estemos al dia.

Manual "Patitas"

# Miguel A:

** La parte que he echo yo es sobre la API, la cual tendra datos de los animales de la protectora **
** La API, siglas de Interfaz de Programación de Aplicaciones sirve para comunicarse con las diferentes partes del software **
** Para hacerlo he utilizado un archivo JSON que carga los datos de los animales de la protectora: **
** 1 - Al buscar la carpeta con los archivos Python, ya que estan en una ruta, se cargan en la API.**
** 2 - La API crea los archivos y se envian a un archivo HTML**
** 3 - El archivo HTML convierte los archivos JSON para mostrarlos en una lista **
** 4 - Se muestra el HTML en la web **

-- PRUEBAS --

<!-- Instrucciones para ejecutar el proyecto con Docker Compose. -->

## Ejecutar con Docker

1. En GitHub Codespaces, abre una terminal en la raíz del proyecto y comprueba que Docker Compose está disponible con `docker compose version`. En Windows local, instala y arranca Docker Desktop con el motor de contenedores Linux habilitado.
2. Nginx necesita los certificados locales `nginx/conf/publica.crt` y `nginx/conf/publica.key`. Si no están en tu copia del proyecto, créalos desde Git Bash con OpenSSL:

   ```bash
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx/conf/publica.key -out nginx/conf/publica.crt -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,DNS:publica.localhost,DNS:descargas.localhost"
   ```

3. Desde la carpeta raíz del proyecto, construye y arranca los servicios:

   ```powershell
   docker compose config
   docker compose up --build -d
   docker compose ps
   ```

4. En Codespaces, abre el puerto `443` desde la pestaña **Ports** y usa su dirección HTTPS. En local, abre `https://localhost`. El certificado local puede mostrar una advertencia del navegador. La página de la API está en `/api.html`, la API JSON en `/api/animales` y los avisos protegidos en `/avisos/`. El sitio de descargas está en `http://descargas.localhost`.
5. Para ejecutar las pruebas desde Git Bash, define las credenciales de un usuario existente en `nginx/conf/usuarios.txt` y ejecuta `bash pruebas.sh`. Sin ellas, se comprueban las rutas públicas y se omite la prueba de autenticación.
6. Para ver los registros o detener los servicios:

   ```powershell
   docker compose logs -f
   docker compose down
   ```

Compose publica solo Nginx; la API y el servidor de avisos se comunican en la red privada de Docker. Los registros de avisos se guardan en la carpeta `logs` del proyecto.
