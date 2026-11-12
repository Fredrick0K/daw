import json
import time
from pathlib import Path

from flask import Flask, jsonify
from waitress import serve

app = Flask(__name__)

# Busca animales.json en la misma carpeta que este archivo Python
RUTA_JSON = Path(__name__).resolve().parent / "animales.json"

try:
    with RUTA_JSON.open("r", encoding="utf-8") as archivo:
        ANIMALES = json.load(archivo)
except FileNotFoundError:
    raise FileNotFoundError(f"No se encontró el archivo: {RUTA_JSON}")
except json.JSONDecodeError as error:
    raise ValueError(f"El archivo JSON no es válido: {error}")

@app.route("/api/animales")
def animales():
    return {"animales": ANIMALES}


@app.route("/api/animales/<int:n>")
def un_animal(n):
    if 1 <= n <= len(ANIMALES):
        return jsonify({"animales": ANIMALES})
    return jsonify({"error": "No existe ese animal"}), 404


@app.route("/api/lenta")
def lenta():
    time.sleep(2)  # Simula un cálculo pesado
    return {"listo": True}


if __name__ == "__main__":
    print("Aplicación en http://127.0.0.1:8000/api/animales (Ctrl+C para parar)")
    serve(app, host="127.0.0.1", port=8000)
