FROM python:3.12-slim AS base

WORKDIR /srv

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app

ENV PORT=5000
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app.app:app"]
