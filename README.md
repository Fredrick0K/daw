###
> [!NOTE]
> ### El trabajo fue hecho por Aritz, Mohammad y Miguel Angel


> [!caution]
>
> ### No subir nada al main, todo a tu rama correspondiente. Cualquir commit puede causar conflictos en futuros merge.
>
> Los nuevos cambios en las ramas se hara merge a la base para que todos estemos al dia.

# Manual del Servidor Web - Protectora Patitas

## 1. Introducción

Este servidor aloja la infraestructura web de la **Protectora de animales "Patitas"**. El sistema está diseñado para dar visibilidad a la protectora, gestionar adopciones, ofrecer documentos informativos y mantener una zona privada para socios.

**Programas que hacen que todo funcione:**

- **Nginx (v1.28.3):** Es el "portero de discoteca igual de grande que un mueble del IKEA" del servidor web. Recibe a todos los visitantes y los dirige a la página correcta o bloquea a los intrusos.
- **Python (v3.12.10):** El cerebro detrás de las funciones más complejas (como la API y el tablón de avisos).
- **Flask y Waitress:** Herramientas para que Python pueda hablar con internet fácilmente.
- **Git 2.55.0:** Para usar la terminal GitBash y tambien para los repositorios en GitHub.

---

## 2. Mapa del Servidor
### Por Aritz y Mohammad

Todo funciona en tu propio ordenador, pero Nginx lo divide en "puertos" como si fueran puertas distintas de un mismo edificio:

- **Puerta HTTP (Puerto 8080):**

  - `publica.localhost`: Si alguien entra por aquí, Nginx lo empuja automáticamente a la puerta segura (HTTPS).
  - `descargas.localhost`: Un servidor tipo "carpeta" que muestra directamente archivos para descargar (fichas, guias).
  - _Cualquier otro intento:_ Cierre de puerta en la cara (Error 444).

- **Puerta HTTPS (Puerto 8443):**

  - La web principal (Portada, Quiénes Somos, Contacto).
  - `/socios/`: Carpeta blindada con contraseña.
  - `/avisos/`: Tablón de anuncios, también blindado.

- **Puertas Traseras (Puertos Internos 8000 y 8001):**
  - Son invisibles para el público. Aquí trabajan los programas de Python y Nginx les pasa la información cuando es necesario.

---

## 3. Cómo Arrancar y Parar Todo
### Por Aritz y Mohammad

No necesitas escribir comandos difíciles. Hemos creado scripts para ello 👍:

- **Para Encender (`bash arrancar.sh`):** Copia los sitios y la configuración local a `nginx-1.28.3`, valida e inicia Nginx y arranca la API y el servidor de avisos. Al final ejecuta automáticamente `pruebas.sh` y guarda el resultado en `pruebas.txt`. Si alguna prueba falla, el script termina con código de error.
- **Para Apagar (`bash parar.sh`):** Mata los procesos de Python y detiene a Nginx de forma segura para no corromper nada.

Para el arranque local necesitas Windows con Git Bash, el bundle incluido `nginx-1.28.3`, Python disponible con el comando `python` y las dependencias de `api/requirements.txt` instaladas. Instálalas desde la raíz del proyecto con `python -m pip install -r api/requirements.txt`. Los puertos locales `8080`, `8443`, `8000` y `8001` deben estar libres.

---

## 4. Zonas Privadas (Solo para Socios)
### Por Aritz

Las secciones `/socios/` y `/avisos/` te pedirán un usuario y contraseña. Las contraseñas están ocultas (cifradas) en el archivo `usuarios.txt` para que nadie pueda leerlas. Hemos usado usuarios en minusculas como convenio ya que python es sensible a las mayusculas y minusculas. ¿Para que complicarse la vida?

**Usuarios autorizados para entrar:**

- `ana`
- `luis`
- `marta`

---

## 5. Seguridad y el "Candado" Verde (HTTPS)
### Por Aritz

La web principal está cifrada con un certificado de seguridad (`publica.crt`). Esto significa que si alguien espía la red, solo verá texto incomprensible.

- **Archivos secretos:** Tenemos reglas (`.gitignore`) para que las claves de seguridad nunca se suban a internet por accidente.
- **Protecciones extra:** Bloqueamos tecnologías antiguas y evitamos que otras webs clonen la nuestra haciéndola pasar por suya.
- **¿Cuándo caduca el certificado?:** Para verlo de forma fácil, abre tu terminal y pega este comando: `openssl x509 -in nginx/conf/publica.crt -noout -enddate`. Yo no lo hago porque ya lo tengo.

---

## 6. Las Páginas de la Web y los Errores
### Por Aritz

La web tiene un diseño unificado (gracias al archivo `estilo.css`) y unas páginas de error amigables para no asustar a los usuarios:

- **Error 404 (`404.html`):** Si alguien escribe mal una dirección, le avisamos de que "un peludo se comió el enlace".
- **Error 50x (`50x.html`):** Si el servidor se cuelga, les decimos que "los gatos tocaron el teclado" 🙀🙀🙀.

---

## 7. Pruebas Automáticas
### Por Aritz y Mohammad

La batería de `pruebas.sh` está pensada para el **Nginx nativo local**, no para Docker Compose. Comprueba la redirección HTTP/HTTPS, las páginas públicas y CSS, la página 404, las cabeceras de seguridad, gzip, la versión de Nginx, el acceso a socios, descargas, API y avisos directos y protegidos. Espera al menos 29 resultados entre pruebas ejecutadas y omitidas.

Ejecuta todo el entorno y las pruebas con Git Bash:

```bash
bash arrancar.sh
```

También puedes ejecutar solo la batería si los servicios locales ya están iniciados:

```bash
bash pruebas.sh
```

Cada resultado aparece como `OK`, `FALLO` u `OMITIDA`. Las comprobaciones que necesitan iniciar sesión correctamente se omiten si no defines credenciales en Git Bash antes de arrancar:

```bash
export SOCIO_USUARIO=ana
export SOCIO_PASSWORD='tu contraseña de ana'
bash arrancar.sh
```

Usa la contraseña en texto claro correspondiente al usuario; `usuarios.txt` guarda hashes, no las contraseñas originales. Las pruebas publican avisos de prueba en el servicio de avisos, por lo que conviene ejecutarlas en un entorno local de pruebas. El `POST` a la API con un cuerpo grande solo comprueba que Nginx lo rechaza con `413` antes de enviarlo a la API. Los resultados de `arrancar.sh` también quedan guardados en `pruebas.txt`.

---

# Miguel A:
### Por Miguel Angel

** La parte que he echo yo es sobre la API, la cual tendra datos de los animales de la protectora **
** La API, siglas de Interfaz de Programación de Aplicaciones sirve para comunicarse con las diferentes partes del software **
** Para hacerlo he utilizado un archivo JSON que carga los datos de los animales de la protectora: **
** 1 - Al buscar la carpeta con los archivos Python, ya que estan en una ruta, se cargan en la API.**
** 2 - La API crea los archivos y se envian a un archivo HTML**
** 3 - El archivo HTML convierte los archivos JSON para mostrarlos en una lista **
** 4 - Se muestra el HTML en la web **

## 8. Logs (El chivato del servidor)
### Por Miguel Angel (Sin hacer) (lo escribio Aritz)

El servidor anota absolutamente todo lo que pasa en unos archivos de texto dentro de la carpeta `logs/`. Si algo falla, mira aquí:

- `logs/publica.log`: Anota quién entra en la web principal, a qué hora y desde qué IP.
- `logs/descargas.log`: Chiva quién se baja los archivos y cuánto pesan.
- `logs/error.log`: Si el servidor explota o se apaga solo, Nginx escribirá aquí el motivo del infarto ❤️‍🩹❤️‍🩹❤️‍🩹.


<!-- Instrucciones para ejecutar el proyecto con Docker Compose.-->


## Ejecucion con Docker
### Por Mohammad 

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

4. En Codespaces, abre el puerto `443` en la pestaña **Ports** y usa la dirección HTTPS que aparece. En local, abre `https://localhost`; el certificado puede mostrar una advertencia porque es autofirmado. La portada de la API está en `/api.html`, los datos JSON en `/api/animales` y los avisos protegidos en `/avisos/`.
5. Comprueba los endpoints de Docker desde la terminal. En Windows local, ejecuta desde Git Bash:

```bash
curl -k -i https://localhost/
curl -k https://localhost/api/animales
curl -i --resolve descargas.localhost:80:127.0.0.1 http://descargas.localhost/
```

En Codespaces, sustituye la URL por la dirección HTTPS del puerto `443` para consultar la web y la API. Para probar el sitio de descargas desde la terminal del propio Codespace, que necesita el nombre de host virtual `descargas.localhost`, ejecuta `curl -i -H 'Host: descargas.localhost' http://127.0.0.1/`. 6. `pruebas.sh` es para el Nginx nativo local (`8080` y `8443`), no para Compose (`80` y `443`). Compose publica solo Nginx; API y avisos son accesibles desde la red privada de Docker. No arranques simultáneamente Docker y el Nginx nativo si ambos intentan usar los mismos puertos del equipo. 7. Para consultar los registros en tiempo real, ejecuta este comando en una terminal. Para salir, pulsa `Ctrl+C`:

```powershell
docker compose logs -f
```

8. Para detener y eliminar los contenedores de este proyecto:

```powershell
docker compose down
```

Los registros del servidor de avisos se guardan en `logs/avisos.log` en el equipo anfitrión.
