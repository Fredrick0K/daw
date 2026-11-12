import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class ServidorPatt(BaseHTTPRequestHandler):
    def do_GET(self):
        time.sleep(2)                       # exactamente lo mismo que en el 15
        datos = b"listo"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(datos)))
        self.end_headers()
        self.wfile.write(datos)

    def log_message(self, formato, *args):
        pass


ThreadingHTTPServer.allow_reuse_address = False

print("CON concurrencia en http://127.0.0.1:8000  (Ctrl+C para parar)")
try:
    ThreadingHTTPServer(("127.0.0.1", 8000), ServidorPatt).serve_forever()
except KeyboardInterrupt:
    print("Servidor parado.")
    
URL = "http://127.0.0.1:8000/api/lenta"      # 127.0.0.1 y no localhost: localhost tarda mas en Windows
N = int(sys.argv[1]) if len(sys.argv) > 1 else 4
hilos = [threading.Thread(target=pedir) for i in range(N)]
print(f"TOTAL para {N} peticiones a la vez: {time.time() - inicio:.2f} s")