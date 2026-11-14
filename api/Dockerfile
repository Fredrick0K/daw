FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
# Instala las dependencias antes de copiar los archivos de la aplicación.
COPY api/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY api/app.py api/animales.json ./

EXPOSE 8000
CMD ["python", "app.py"]