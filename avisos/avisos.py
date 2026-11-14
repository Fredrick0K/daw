import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime

# BASE DE DATOS EN MEMORIA (RAM): 
# Al no usar un archivo de texto o base de datos externa, esta lista es volátil.
# Si el servidor se apaga o reinicia, todo lo que los usuarios hayan añadido desaparecerá y volverá a empezar solo con estos dos avisos.
AVISOS = [
    "Necesitamos mantas y toallas viejas para el invierno.",
    "Han llegado 3 nuevos cachorros. Hablad con Ana."
]

# MANEJADOR DE PETICIONES HTTP:
# Esta clase actúa como "traductor". Interpreta el texto crudo del protocolo HTTP que llega por la red y decide qué funciones ejecutar dependiendo del método (GET, POST, etc.) que mandó el cliente.
class Manejador(BaseHTTPRequestHandler):
    
    # MOTOR DE RESPUESTAS Y LOG:
    # Esta función automatiza el proceso de enviar datos por internet: primero convierte los diccionarios de Python a texto JSON (json.dumps), y luego lo codifica a bytes (UTF-8) porque las redes solo entienden ceros y unos.
    # A continuación, construye la respuesta HTTP estándar: envía el código de estado, avisa del tipo de contenido, manda el peso exacto (para que el navegador sepa cuándo ha terminado de cargar) y finalmente escupe el JSON.
    # Después, usa 'datetime' y las variables internas de la clase para formatear una línea de log y añadirla al final (modo "a", append) del archivo avisos.log.
    def enviar_json(self, estado, cuerpo):
        datos = json.dumps(cuerpo).encode("utf-8")
        self.send_response(estado)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(datos)))
        self.end_headers()
        self.wfile.write(datos)
        
        momento = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        linea = f'{self.client_address[0]} [{momento}] "{self.command} {self.path}" {estado} {len(datos)}'
        with open("logs/avisos.log", "a", encoding="utf-8") as f:
            f.write(linea + "\n")

    # MÉTODO DE LECTURA (GET):
    # Se dispara automáticamente cuando Nginx (o el cliente) pide leer datos. Verifica estrictamente que la ruta (self.path) sea /avisos. Si lo es, reenvía la lista entera de Python usando el motor que definimos arriba con un éxito 200. Si alguien intenta entrar a /avisos/otra-cosa, falla y escupe un 404.
    def do_GET(self):
        if self.path == "/avisos":
            self.enviar_json(200, AVISOS)
        else:
            self.enviar_json(404, {"error": "No existe"})

    # MÉTODO DE ESCRITURA (POST):
    # Se dispara cuando el cliente envía datos (payload) para guardarlos. 
    # Como los datos llegan en un flujo contínuo (stream), primero lee la cabecera 'Content-Length' para saber exactamente cuántos bytes tiene que leer. 
    # Luego extrae esos bytes de 'self.rfile', los decodifica a texto legible, y si hay contenido válido, lo inyecta (.append) en nuestra lista de memoria RAM, devolviendo un estado 201 (recurso Creado exitosamente).
    def do_POST(self):
        longitud = int(self.headers.get("Content-Length", 0))
        texto = self.rfile.read(longitud).decode("utf-8").strip()
        if self.path == "/avisos" and texto:
            AVISOS.append(texto)
            self.enviar_json(201, {"nuevo": texto, "avisos": len(AVISOS)})
        else:
            self.enviar_json(404, {"error": "No existe"})

# ARRANQUE DEL SERVIDOR:
# Este bloque garantiza que el servidor web solo se encienda si ejecutamos este archivo directamente desde la terminal.
# 'ThreadingHTTPServer' es clave aquí: en lugar de procesar a los usuarios de uno en uno (lo que crearía cuellos de botella), crea un "hilo" (thread) independiente en el procesador por cada usuario que se conecte, atendiendo a todos simultáneamente[cite: 22].
if __name__ == '__main__':
    servidor = ThreadingHTTPServer(('127.0.0.1', 8001), Manejador)
    print("Servidor de avisos (JSON) activo en el puerto 8001")
    servidor.serve_forever()