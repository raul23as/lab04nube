# Imagen base - Python oficial
FROM python:3.11-slim

# Metadata
LABEL maintainer="tu-email@ejemplo.com"
LABEL description="Consulta Miembro de Mesa ONPE"

# Instalar Chromium y ChromeDriver
RUN apt-get update && apt-get install -y \
    chromium chromium-driver \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno para que Selenium use Chromium del sistema
ENV CHROME_BINARY=/usr/bin/chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivo de dependencias
COPY requirements.txt .

# Instalar dependencias Python (selenium-manager maneja ChromeDriver automaticamente)
RUN pip install --no-cache-dir -r requirements.txt

# Copiar todo el codigo de la aplicacion
COPY . .

# Exponer el puerto
EXPOSE 5000

# Comando por defecto
CMD ["python", "app.py"]
