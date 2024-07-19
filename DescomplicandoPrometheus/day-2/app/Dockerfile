# Vamos utilizar a imagem slim do Python
FROM python:3.8-slim

# Adicionando algumas labels para identificar a imagem
LABEL maintainer Ernane CL <ernane_cruz@hotmail.com>
LABEL description "Dockerfile para criar a imagem de container do nosso primeiro exporter para o Prometheus"

# Adicionando o exporter.py para a nossa imagem
WORKDIR /app
COPY . /app

# Instalando as bibliotecas necessárias para o exporter
# através do `requirements.txt`.
RUN pip3 install -r requirements.txt

# Executando o exporter
CMD python3 exporter.py

# conteudo original: https://github.com/badtuxx/DescomplicandoPrometheus/blob/main/pt/src/day-2/README.md#nosso-primeiro-exporter-no-container