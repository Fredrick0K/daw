import json
import time
from pathlib import Path

from flask import Flask
from waitress import serve

app = Flask(__name__)

with (Path(__file__).parent / "animales.json").open(encoding="utf-8") as archivo:
    ANIMALES = json.load(archivo)

@app.route("/api/animales")
def animales():
    return {"animales": ANIMALES}

@app.route("/api/animales/<int:n>")
def un_animal(n):
    if 1 <= n <= len(ANIMALES):
        return {"n": n, "animal": ANIMALES[n - 1]}
    return {"error": "No existe ese animal"}, 404

@app.route("/api/lenta")
def lenta():
    time.sleep(2)
    return {"listo": True}

print("Aplicacion en http://127.0.0.1:8000  (Ctrl+C para parar)")
serve(app, host="127.0.0.1", port=8000)