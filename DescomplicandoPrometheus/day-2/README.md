## Extra content

### Data Model
#### Seach metrics through the terminal

    curl localhost:9090/metrics


#### Get information in text mode via the terminal.

Curl is a program that allows you to make HTTP requests, that is, you can make requests to a URL and receive a response.

#### In this case, we are asking you to make a GET on the URL and send a query to Prometheus.

    http://localhost:9090/api/v1/query


In the example, we are passing our "up" metric and we are also passing the "--data-urlencode" parameter to curl, which is a parameter that allows you to POST data via URL, similar to curl's --data parameter.

    curl -GET localhost:9090/api/v1/query --data-urlencode "query=up"


#### To better handle the output we can add the command "| jq ."

    curl -GET localhost:9090/api/v1/query --data-urlencodse "query=up" | jq .


#### To use the "jq" command we need to install it
to install it use the following command

    apt install jq -y


#### Content

    https://www.cyberithub.com/how-to-install-jq-json-processor-on-debian-10-11/


#### Data model - Prometheus

    metric {label_name="label_value"}   value


Exemple

    up {instance="localhost:9090", job="prometheus"}   1


### Exporter
In this step we will create an exporter with Python.

Starting with the creation of the exporter.py file
    
    touch exporter.py
    chmod +x exporter.py


#### The code to put in the exporter.py file
    
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

#### To install them, run the commands below

    pip install requests
    pip install prometheus-client


#### The official document of the prometheus-client library

    github.com/prometheus/client_python


#### If you don`t have a pip package, install it with the following command
   
    sudo apt install python3-pip


#### View exporter metrics on port 8899
Through the terminal, run the command below to check if everything is ok
   
    curl http://localhost:8899/metrics/


#### Remembering that you can access via browser by accessing the following URL
    
    http://localhost:8899/metrics/


### Docker container exporter
We need to create a Dockerfile document for the container.

Then we add the following content:
    
    # Vamos utilizar a imagem slim do Python
    FROM python:3.8-slim

    # Adicionando algumas labels para identificar a imagem
    LABEL maintainer Ernane <email@email.com>
    LABEL description "Dockerfile para criar a imagem de container do nosso primeiro exporter para o Prometheus"

    # Indicando qual diretorio esta trabalhando e adicionando o exporter.py para a nossa imagem
    WORKDIR /app
    COPY . /app

    # Instalando as bibliotecas necessárias para o exporter
    # através do `requirements.txt`.
    RUN pip3 install -r requirements.txt

    # Executando o exporter
    CMD python3 exporter.py


#### Installing Docker
    
    curl -fsSL https://get.docker.com | bash
    

#### Check if something is running in Docker
    
    sudo docker ps


#### Create container 
    
    sudo docker build -t first-exporter:0.1 .


#### Check Docker image

    sudo docker image ls | grep first-exporter


#### Run and export to port 8899 of the machine and container
    
    sudo docker run -d -p 8899:8899 --name first-exporter first-exporter:0.1

### Setting Target

#### View target hosts

    curl -s http://localhost:9090/api/v1/targets
    curl -s http://localhost:9090/api/v1/targets | jq .


#### Access prometheus.yml file

    sudo vim /etc/prometheus/prometheus.yml

#### Add the following contents

    - job_name: "primeiro exporter" 
      static_configs:
        - targets: ["localhost:8899"]

#### The final file will look like the example below

    global:
        scrape_interval: 15s
        evaluation_interval: 15s
        scrape_timeout: 10s

    rule_files:

    scrape_configs:
        - job_name: "prometheus"
          static_configs: 
            - targets: ["localhost:9090"]

        - job_name: "primeiro exporter" 
          static_configs:
            - targets: ["localhost:8899"]


#### Restarting Prometheus

    sudo systemctl restart prometheus


#### Check Prometheus status

    sudo systemctl status prometheus


#### Get Prometheus targets from the terminal

    curl -s localhost:9090/api/v1/targets | jq .


#### Get Prometheus targets from the terminal, specifying the port

    curl -s localhost:9090/api/v1/targets | jq . | grep -i "localhost:8899"


#### Get Prometheus query from the terminal, specifying the query

    curl -s localhost:9090/api/v1/query?query=numero_de_astronautas | jq .


### Adding news metrics to the exporter
Let's add more metrics to our exporter.py file.
In this case, we'll add metrics for the location of the ISS (International Space Station) with latitude and longitude.

#### The updated file will follow the model below

    import requests # Importa o módulo requests para fazer requisições HTTP
    import json # Importa o módulo json para converter o resultado em JSON
    import time # Importa o módulo time para fazer o sleep
    from prometheus_client import start_http_server, Gauge # Importa o módulo Gauge do Prometheus para criar a nossa métrica e o módulo start_http_server para iniciar o servidor

    url_numero_pessoas = 'http://api.open-notify.org/astros.json' # URL para pegar o número de astronautas
    url_local_ISS = 'http://api.open-notify.org/iss-now.json' # URL para pegar a localização do ISS

    def pega_local_ISS(): # Função para pegar a localização da ISS
        try:
            """
            Pegar o local da estação espacial internacional
            """
            response = requests.get(url_local_ISS) # Faz a requisição para a URL
            data = response.json() # Converte o resultado em JSON
            return data['iss_position'] # Retorna o resultado da requisição
        except Exception as e: # Caso ocorra algum erro
            print("Não foi possível acessar a url!") # Imprime uma mensagem de erro
            raise e # Lança a exceção

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
            longitude = Gauge('longitude_ISS', 'Longitude da Estação Espacial Internacional') # Cria a métrica para a longitude da estação espacial internacional
            latitude = Gauge('latitude_ISS', 'Latitude da Estação Espacial Internacional') # Cria a métrica para a latitude da estação espacial internacional

            while True: # Enquanto True
                numero_pessoas.set(pega_numero_astronautas()) # Atualiza a métrica com o número de astronautas
                longitude.set(pega_local_ISS()['longitude']) # Atualiza a métrica com a longitude da estação espacial internacional
                latitude.set(pega_local_ISS()['latitude']) # Atualiza a métrica com a latitude da estação espacial internacional
                time.sleep(10) # Faz o sleep de 10 segundos
                print("O número atual de astronautas no espaço é: %s" % pega_numero_astronautas()) # Imprime o número atual de astronautas no espaço
                print("A longitude atual da Estação Espacial Internacional é: %s" % pega_local_ISS()['longitude']) # Imprime a longitude atual da estação espacial internacional
                print("A latitude atual da Estação Espacial Internacional é: %s" % pega_local_ISS()['latitude']) # Imprime a latitude atual da estação espacial internacional
        except Exception as e: # Se der algum erro
            print("Problemas para atualizar as métricas! \n\n====> %s \n" % e) # Imprime que ocorreu um problema para atualizar as métricas
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


#### GitHub:
    
    https://github.com/badtuxx/DescomplicandoPrometheus/blob/main/pt/src/day-2/README.md#o-nosso-primeiro-exporter


#### Open Notify - People in Space:

    http://open-notify.org/Open-Notify-API/People-In-Space/


#### Open Notify - ISS Location Now:

    http://open-notify.org/Open-Notify-API/ISS-Location-Now/


#### Running exporter.py
After updating the file, use the following command to run exporter.py.

    python3 exporter.py


If you are having trouble with http, it is likely that Docker is running.
Use the command below to shut down Docker and run exporter.py again.

    docker rm -f first-exporter
    python exporter.py


#### Buillding Docker
Creating a new Docker image
    
    docker build -t first-exporter:1.0 .


#### Listing Docker images
    
    docker images | grep first-exporter


#### Running Docker

    docker run -d -p 8899:8899 first-exporter:1.0


#### Listing running Docker

    sudo docker ps | grep first-exporter


#### Check if our metrics are reaching Prometheus

    # longitude_ISS
    curl -s http://localhost:9090/api/v1/query\?query\=longitude_ISS | jq .
    
    # latitude_ISS
    curl -s http://localhost:9090/api/v1/query\?query\=latitude_ISS | jq .


#### Getting metrics through the terminal

    curl localhost:8899/metrics


### Understanding Prometheus data types
#### Original Material

    https://github.com/badtuxx/DescomplicandoPrometheus/blob/main/pt/src/day-2/README.md#conhecendo-um-pouco-mais-sobre-os-tipos-de-dados-do-prometheus


#### **gauge: Medidor**
  - O tipo de dado `gauge` é o tipo de dado utilizado para criar métricas que podem ter seus valores alterados para cima ou para baixo, por exemplo, a ultilização de memória ou cpu. Se quiser trazer para exemplos da vida real, podemos falar que aquelas filas que você odeia é o tipo de dado `gauge`, ou então a temperatura da sua cidade, ela pode ser alterada para cima ou para baixo, ou seja, é um medidor, é um `gauge`! :D
  Um exemplo de métrica do tipo `gauge` é a métrica `memory_usage`, que é uma métrica que mostra a utilização de memória.

      ```PROMQL
      memory_usage{instance="localhost:8899",job="Primeiro Exporter"}
      ```

&nbsp;

#### **counter: Contador**
  - O tipo de dado `counter` é o tipo de dado utilizado que vai ser incrementado no decorrer do tempo, por exemplo, quando eu quero contar os erros em uma aplicação no decorrer da última hora.
  O valor atual do `counter` quase nunca é importante, pois o que queremos dele são os valores durante uma janela de tempo, por exemplo, quantas vezes a minha aplicação falhou durante o final de semana.
  Normalmente as métricas `counter` possuem o sufixo `_total` para indicar que é o total de valores que foram contados, por exemplo:

    ```PROMQL
    requests_total{instance="localhost:8899",job="Primeiro Exporter"}
    ```

&nbsp;

#### **histogram: Histograma**
  - O tipo de dado `histogram` é o tipo de dado que te permite especificar o seu valor através de buckets predefinidos, por exemplo, o tempo de execução de uma aplicação. Com o `histogram` eu consigo contar todas as requisições que minha aplicação respondeu entre 0 e 0,5 segundos, ou então as requisições que tiveram respostas entre 1,0 e 2,5 e assim por diante.
  Por padrão, os buckets predefinidos são até no máximo 10 segundos, se você quiser mais, você pode criar seus próprios buckets personalizados.
  Um coisa super importante, o Prometheus irá contar cada item em cada bucket, e também a soma dos valores.
  Uma métrica do tipo `histogram` inclui alguns itens importantes são adicionados ao final do nome da métrica para indicar o tipo de dado e o tamanho do bucket, por exemplo:

    ```PROMQL
    requests_duration_seconds_bucket{le="0.5"}
    ```

    Onde `le` é o valor limite do bucket, o valor `0.5` indica que o valor do bucket é até 0,5 segundos, ou seja, aqui nesse bucket poderiam estar os requisições que tiveram respostas entre 0 e 0,5 segundos.

    O `_bucket` é um sufixo que indica que o valor é um bucket.

    Ainda temos alguns sufixos que são importantes e que podem ser úteis para nós:

    - _count: Contador
        - O sufixo `_count` indica que o valor é um contador, ou seja, o valor é incrementado a cada vez que a métrica é atualizada.

    - _sum: Soma
       - O sufixo `_sum` indica que o valor é uma soma, ou seja, o valor é somado a cada vez que a métrica é atualizada.

  - _bucket: Bucket
      - O sufixo `_bucket` indica que o valor é um bucket, ou seja, o valor é um bucket.

        O ponto alto do `histogram` é a excelente flexibilidades, pois percentuais e as janelas de tempos podem definidas durante a criação das queries, o ponto negativo é a precisão é um pouco inferior quando comparado com o `summary`.

&nbsp;

#### **summary: Resumo**
  - O tipo de dado `summary` é bem parecido com o `histogram`, com a diferença que os buckets, aqui chamados de `quantiles`, são definidos por um valor entre 0 e 1, ou seja, o valor do bucket é o valor que está entre os quantiles.

    Da mesma forma como no `histogram`, podemos criar métricas do tipo `summary` com alguns itens importantes adicionados ao final do nome da métrica, por exemplo:
  
    ```PROMQL
    requests_duration_seconds_sum{instance="localhost:8899",job="Primeiro Exporter"}
    ```

    Utilizamos o sufixo `_sum` indica que o valor é uma soma, ou seja, o valor é somado a cada vez que a métrica é atualizada e o sufixo `_count` para indicar que o valor é um contador, ou seja, o valor é incrementado a cada vez que a métrica é atualizada.

    O ponto alto do `summary` é a excelente precisão e o ponto baixo é a baixa flexibilidades, pois percentuais e as janelas de tempos precisam ser definidos durante a criação da métrica e não é possível agregar métricas do tipo `summary` com outras métricas do tipo `summary` durante a criação das queries.


Percebam que em nosso primeiro exporter, nós somente utilizamos métricas do tipo `gauge`, pois queremos saber quantas pessoas estão no espaço e também a localização da ISS (International Space Station) ao longo do tempo. 