FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
# Compose monta este directorio de registros desde el equipo anfitrión.
RUN mkdir -p /app/logs
COPY avisos/avisos.py ./avisos.py

EXPOSE 8001
CMD ["python", "avisos.py"]