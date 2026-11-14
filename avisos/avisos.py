import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime

# Lista inicial con vuestros dos avisos
AVISOS = [
    "Necesitamos mantas y toallas viejas para el invierno.",
    "Han llegado 3 nuevos cachorros. Hablad con Ana."
]

class Manejador(BaseHTTPRequestHandler):
    def enviar_json(self, estado, cuerpo):
        datos = json.dumps(cuerpo).encode("utf-8")
        self.send_response(estado)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(datos)))
        self.end_headers()
        self.wfile.write(datos)
        
        # Escribir la línea en el log de avisos
        momento = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        linea = f'{self.client_address[0]} [{momento}] "{self.command} {self.path}" {estado} {len(datos)}'
        with open("logs/avisos.log", "a", encoding="utf-8") as f:
            f.write(linea + "\n")

    def do_GET(self):
        if self.path == "/avisos":
            self.enviar_json(200, AVISOS)
        else:
            self.enviar_json(404, {"error": "No existe"})

    def do_POST(self):
        longitud = int(self.headers.get("Content-Length", 0))
        texto = self.rfile.read(longitud).decode("utf-8").strip()
        if self.path == "/avisos" and texto:
            AVISOS.append(texto)
            self.enviar_json(201, {"nuevo": texto, "avisos": len(AVISOS)})
        else:
            self.enviar_json(404, {"error": "No existe"})

if __name__ == '__main__':
    # Usamos ThreadingHTTPServer para atender varios clientes a la vez en el puerto 8001
    servidor = ThreadingHTTPServer(('127.0.0.1', 8001), Manejador)
    print("Servidor de avisos (JSON) activo en el puerto 8001")
    servidor.serve_forever()