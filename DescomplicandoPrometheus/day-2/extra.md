## Extra content

### Data Model
Seach metrics through the terminal
    curl localhost:9090/metrics

Get information in text mode via the terminal
Curl is a program that allows you to make HTTP requests, that is, you can make requests to a URL and receive a response.
In this case, we are asking you to make a GET on the URL http://localhost:9090/api/v1/query and send a query to Prometheus.
In the example, we are passing our "up" metric and we are also passing the "--data-urlencode" parameter to curl, which is a parameter that allows you to POST data via URL, similar to curl's --data parameter.
    curl -GET localhost:9090/api/v1/query --data-urlencode "query=up"

To better handle the output we can add the command "| jq ."
    curl -GET localhost:9090/api/v1/query --data-urlencodse "query=up" | jq .

To use the "jq" command we need to install it
to install it use the following command
    apt install jq -y

content: https://www.cyberithub.com/how-to-install-jq-json-processor-on-debian-10-11/

Data model - Prometheus
    metric {label_name="label_value"}   value

    Exemple
        up {instance="localhost:9090", job="prometheus"}   1

### Exporter
In this step we will create an exporter with Python
starting with the creation of the exporter.py file
    touch exporter.py
    chmod +x exporter.py

The code to put in the exporter.py file
    import requests # Importa o módulo requests para fazer requisições HTTP
    import json # Importa o módulo json para converter o resultado em JSON
    import time # Importa o módulo time para fazer o sleep
    from prometheus_client import start_http_server, Gauge # Importa o módulo Gauge do Prometheus para criar a nossa métrica e o módulo start_http_server para iniciar o servidor

    url_numero_pessoas = 'http://api.open-notify.org/astros.json' # URL para pegar o número de astronautas

    def pega_numero_astronautas(): # Função para pegar o número de astronautas
        try: # Tenta fazer a requisição HTTP
            """
            Pegar o número de astronautas no espaço 
            """
            response = requests.get(url_numero_pessoas) # Faz a requisição HTTP
            data = response.json() # Converte o resultado em JSON
            return data['number'] # Retorna o número de astronautas
        except Exception as e: # Se der algum erro
            print("Não foi possível acessar a url!") # Imprime que não foi possível acessar a url
            raise e # Lança a exceção

    def atualiza_metricas(): # Função para atualizar as métricas
        try:
            """
            Atualiza as métricas com o número de astronautas e local da estação espacial internacional
            """
            numero_pessoas = Gauge('numero_de_astronautas', 'Número de astronautas no espaço') # Cria a métrica
            
            while True: # Enquanto True
                numero_pessoas.set(pega_numero_astronautas()) # Atualiza a métrica com o número de astronautas
                time.sleep(10) # Faz o sleep de 10 segundos
                print("O número atual de astronautas no espaço é: %s" % pega_numero_astronautas()) # Imprime o número de astronautas no espaço
        except Exception as e: # Se der algum erro
            print("A quantidade de astronautas não pode ser atualizada!") # Imprime que não foi possível atualizar a quantidade de astronautas
            raise e # Lança a exceção
            
    def inicia_exporter(): # Função para iniciar o exporter
        try:
            """
            Iniciar o exporter
            """
            start_http_server(8899) # Inicia o servidor do Prometheus na porta 8899
            return True # Retorna True
        except Exception as e: # Se der algum erro
            print("O Servidor não pode ser iniciado!") # Imprime que não foi possível iniciar o servidor
            raise e # Lança a exceção

    def main(): # Função principal
        try:
            inicia_exporter() # Inicia o exporter
            print('Exporter Iniciado') # Imprime que o exporter foi iniciado
            atualiza_metricas() # Atualiza as métricas
        except Exception as e: # Se der algum erro
            print('\nExporter Falhou e Foi Finalizado! \n\n======> %s\n' % e) # Imprime que o exporter falhou e foi finalizado
            exit(1) # Finaliza o programa com erro


    if __name__ == '__main__': # Se o programa for executado diretamente
        main() # Executa o main
        exit(0) # Finaliza o programa

The exporter has the function of requesting the number of people in the space from the URL(), with the definition of the port (8899) for the metrics and the condition of updating the metric every 10 seconds.

If you need to install any Python library like "requests" or "prometheus-client" run the commands below
"requests" and "prometheus-client" are Python libraries
to install them, run the commands below
    pip install requests
    pip install prometheus-client

prometheus-client library official document:
    github.com/prometheus/client_python

If you don`t have a pip package, install it with the following command
    sudo apt install python3-pip

View exporter metrics on port 8899
through the terminal, run the command below to check if everything is ok
    curl http://localhost:8899/metrics/

Remembering that you can access via browser by accessing the following URL
    http://localhost:8899/metrics/

### Queries