# Manual del Servidor Web - Protectora Patitas

## 1. Introducción
Este servidor aloja la infraestructura web de la **Protectora de animales "Patitas"**. El sistema está diseñado para dar visibilidad a la protectora, gestionar adopciones, ofrecer documentos informativos y mantener una zona privada para socios.

**Programas que hacen que todo funcione:**
* **Nginx (v1.28.3):** Es el "portero de discoteca igual de grande que un mueble del IKEA" del servidor web. Recibe a todos los visitantes y los dirige a la página correcta o bloquea a los intrusos.
* **Python (v3.12.10):** El cerebro detrás de las funciones más complejas (como la API y el tablón de avisos).
* **Flask y Waitress:** Herramientas para que Python pueda hablar con internet fácilmente.
* **Git 2.55.0:** Para usar la terminal GitBash y tambien para los repositorios en GitHub.

---

## 2. Mapa del Servidor (Dónde está cada cosa)
Todo funciona en tu propio ordenador, pero Nginx lo divide en "puertos" como si fueran puertas distintas de un mismo edificio:

* **Puerta HTTP (Puerto 8080 - Tráfico normal):**
  * `publica.localhost`: Si alguien entra por aquí, Nginx lo empuja automáticamente a la puerta segura (HTTPS).
  * `descargas.localhost`: Un servidor tipo "carpeta" que muestra directamente archivos para descargar (fichas, guias).
  * *Cualquier otro intento:* Cierre de puerta en la cara (Error 444).

* **Puerta HTTPS (Puerto 8443 - Tráfico seguro con candado):**
  * La web principal (Portada, Quiénes Somos, Contacto).
  * `/socios/`: Carpeta blindada con contraseña.
  * `/avisos/`: Tablón de anuncios, también blindado.

* **Puertas Traseras (Puertos Internos 8000 y 8001):**
  * Son invisibles para el público. Aquí trabajan los programas de Python y Nginx les pasa la información cuando es necesario.

---

## 3. Cómo Arrancar y Parar Todo
No necesitas escribir comandos difíciles. Hemos creado scripts para ello 👍:

* **Para Encender (`bash arrancar.sh`):** Carga la configuración y despierta a Nginx y a los programas de Python para que trabajen en segundo plano.
* **Para Apagar (`bash parar.sh`):** Mata los procesos de Python y detiene a Nginx de forma segura para no corromper nada.

---

## 4. Zonas Privadas (Solo para Socios)
Las secciones `/socios/` y `/avisos/` te pedirán un usuario y contraseña. Las contraseñas están ocultas (cifradas) en el archivo `usuarios.txt` para que nadie pueda leerlas. Hemos usado usuarios en minusculas como convenio ya que python es sensible a las mayusculas y minusculas. ¿Para que complicarse la vida?

**Usuarios autorizados para entrar:**
* `ana`
* `luis`
* `marta`

---

## 5. Seguridad y el "Candado" Verde (HTTPS)
La web principal está cifrada con un certificado de seguridad (`publica.crt`). Esto significa que si alguien espía la red, solo verá texto incomprensible.

* **Archivos secretos:** Tenemos reglas (`.gitignore`) para que las claves de seguridad nunca se suban a internet por accidente.
* **Protecciones extra:** Bloqueamos tecnologías antiguas y evitamos que otras webs clonen la nuestra haciéndola pasar por suya.
* **¿Cuándo caduca el certificado?:** Para verlo de forma fácil, abre tu terminal y pega este comando: `openssl x509 -in nginx/conf/publica.crt -noout -enddate`. Yo no lo hago porque ya lo tengo.

---

## 6. Las Páginas de la Web y los Errores
La web tiene un diseño unificado (gracias al archivo `estilo.css`) y unas páginas de error amigables para no asustar a los usuarios:
* **Error 404 (`404.html`):** Si alguien escribe mal una dirección, le avisamos de que "un peludo se comió el enlace".
* **Error 50x (`50x.html`):** Si el servidor se cuelga, les decimos que "los gatos tocaron el teclado" 🙀🙀🙀.

---

## 7. Pruebas Automáticas
Si crees que algo se ha roto, ejecuta `bash pruebas.sh`. Es un script que intentará entrar en todas las páginas por ti y te dirá si responden bien (OK) o si fallan, comprobando bloqueos y redirecciones sin que tengas que abrir el navegador.

---

## 8. Logs (El chivato del servidor)
El servidor anota absolutamente todo lo que pasa en unos archivos de texto dentro de la carpeta `logs/`. Si algo falla, mira aquí:

* `logs/publica.log`: Anota quién entra en la web principal, a qué hora y desde qué IP.
* `logs/descargas.log`: Chiva quién se baja los archivos y cuánto pesan.
* `logs/error.log`: Si el servidor explota o se apaga solo, Nginx escribirá aquí el motivo del infarto ❤️‍🩹❤️‍🩹❤️‍🩹.