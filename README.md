# Consulta Miembro de Mesa - ONPE

Aplicación Flask que verifica si uno o varios DNIs pertenecen a miembros de mesa electoral del ONPE, automatizando la consulta con Selenium para superar el reCAPTCHA y la autenticación JWT del sitio.

---

## Estructura del proyecto

```
sem04-caso2/
├── app.py                  # Aplicación Flask principal
├── requirements.txt        # Dependencias Python
├── Dockerfile              # Imagen base (python:3.11-slim + Chromium)
├── Dockerfile.optimizado   # Imagen optimizada (Alpine + Chromium)
├── Dockerfile.multistage   # Imagen multistage (Alpine 2 etapas)
├── .dockerignore
└── templates/
    └── index.html          # Interfaz web
```

---

## Requisitos

- Python 3.11+
- Google Chrome instalado (para ejecución local)
- Docker (para ejecución en contenedor)

---

## Ejecución local

### 1. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 2. Iniciar el servidor

```bash
python app.py
```

### 3. Abrir en el navegador

```
http://localhost:5000
```

---

## Uso de la aplicación

1. Ingresa uno o varios DNIs en el área de texto.
2. Acepta separadores: salto de línea, coma `,`, punto y coma `;` o espacio.
3. Haz clic en **Consultar**.
4. Los resultados muestran: DNI, si es miembro, rol/cargo, nombre completo, región, provincia, distrito y dirección del local.
5. Usa **Descargar Excel** para exportar los resultados.

---

## Cómo funciona

1. Selenium abre Chrome en modo headless y navega a `https://consultaelectoral.onpe.gob.pe/inicio`.
2. Ingresa el DNI en el formulario y hace clic en el botón de consulta.
3. Intercepta las respuestas de red vía Chrome DevTools Protocol (CDP).
4. Filtra la respuesta del endpoint `/v1/api/consulta/definitiva` que contiene los datos del elector.
5. Parsea los campos: `miembroMesa`, `nombres`, `apellidos`, `ubigeo`, `cargo`, `localVotacion`, `direccion`.

---

## Variables de entorno

| Variable           | Descripción                              | Ejemplo (Docker)                  |
|--------------------|------------------------------------------|-----------------------------------|
| `CHROME_BINARY`    | Ruta al binario de Chromium              | `/usr/bin/chromium-browser`       |
| `CHROMEDRIVER_PATH`| Ruta al ChromeDriver                     | `/usr/bin/chromedriver`           |

> En ejecución local sin estas variables, Selenium usa `selenium-manager` para descargar el driver automáticamente.

---

## Docker

### Construir imágenes

```bash
# Imagen base (Debian slim)
docker build -t onpe-app:v1.0 .

# Imagen optimizada (Alpine)
docker build -f Dockerfile.optimizado -t onpe-app:v1.1-alpine .

# Imagen multistage (Alpine 2 etapas)
docker build -f Dockerfile.multistage -t onpe-app:v1.2-multistage .
```

### Ejecutar

```bash
docker run -d -p 5000:5000 --name onpe-container onpe-app:v1.0
```

Abre `http://localhost:5000` en el navegador.

### Comparar tamaños

```bash
docker images | grep onpe-app
```

| Tag               | Base              | Tamaño aprox. |
|-------------------|-------------------|---------------|
| `v1.0`            | python:3.11-slim  | ~600 MB       |
| `v1.1-alpine`     | python:3.11-alpine| ~420 MB       |
| `v1.2-multistage` | Alpine 2 etapas   | ~400 MB       |

> El tamaño es mayor de lo habitual porque Chromium añade ~300 MB. La diferencia entre imágenes sigue siendo notable.

### Detener y limpiar

```bash
docker stop onpe-container
docker rm onpe-container
```

---

## Dependencias

```
Flask==3.0.0
selenium==4.21.0
openpyxl==3.1.2
```

---

## Notas técnicas

- El sitio ONPE usa reCAPTCHA v3 y JWT, por eso se usa Selenium en lugar de llamadas directas a la API.
- `selenium-manager` (incluido en Selenium 4.6+) descarga el ChromeDriver compatible automáticamente en ejecución local.
- En Docker se usan `CHROME_BINARY` y `CHROMEDRIVER_PATH` para apuntar al Chromium instalado en la imagen Alpine.
- El campo `miembroMesa` (boolean) determina si el DNI es miembro de mesa.
- El campo `ubigeo` viene en formato `"REGION / PROVINCIA / DISTRITO"` y se parsea al vuelo.
