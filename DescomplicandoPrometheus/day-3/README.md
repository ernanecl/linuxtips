## Content

### Configuring new exporter using Golang

You need to install the `Go` package, to install `Go` on `Debian`, just run the following command.

```BASH
sudo apt install golang
```
&nbsp;

#### Creating the exporter using Go

Let's create a file called `second-exporter.go` in `second-exporter directory`.

And let's add the following code.

```GO
package main

import ( // importando as bibliotecas necessárias
    "log"      // log
    "net/http" // http

    "github.com/pbnjay/memory"                                // biblioteca para pegar informações de memória
    "github.com/prometheus/client_golang/prometheus"          // biblioteca para criar o nosso exporter
    "github.com/prometheus/client_golang/prometheus/promhttp" // biblioteca criar o servidor web
)

func memoriaLivre() float64 { // função para pegar a memória livre
    memoria_livre := memory.FreeMemory() // pegando a memória livre através da função FreeMemory() da biblioteca memory
    return float64(memoria_livre)        // retornando o valor da memória livre
}

func totalMemory() float64 { // função para pegar a memória total
    memoria_total := memory.TotalMemory() // pegando a memória total através da função TotalMemory() da biblioteca memory
    return float64(memoria_total)         // retornando o valor da memória total
}

var ( // variáveis para definir as nossas métricas do tipo Gauge
    memoriaLivreBytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{ // métrica para pegar a memória livre em bytes
        Name: "memoria_livre_bytes",                  // nome da métrica
        Help: "Quantidade de memória livre em bytes", // descrição da métrica
    })

    memoriaLivreMegabytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{ // métrica para pegar a memória livre em megabytes
        Name: "memoria_livre_megabytes",                  // nome da métrica
        Help: "Quantidade de memória livre em megabytes", // descrição da métrica
    })

    totalMemoryBytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{ // métrica para pegar a memória total em bytes
        Name: "total_memoria_bytes",                  // nome da métrica
        Help: "Quantidade total de memória em bytes", // descrição da métrica
    })

    totalMemoryGigaBytesGauge = prometheus.NewGauge(prometheus.GaugeOpts{ // métrica para pegar a memória total em gigabytes
        Name: "total_memoria_gigabytes",                  // nome da métrica
        Help: "Quantidade total de memória em gigabytes", // descrição da métrica
    })
)

func init() { // função para registrar as métricas

    prometheus.MustRegister(memoriaLivreBytesGauge)     // registrando a métrica de memória livre em bytes
    prometheus.MustRegister(memoriaLivreMegabytesGauge) // registrando a métrica de memória livre em megabytes
    prometheus.MustRegister(totalMemoryBytesGauge)      // registrando a métrica de memória total em bytes
    prometheus.MustRegister(totalMemoryGigaBytesGauge)  // registrando a métrica de memória total em gigabytes
}

func main() { // função principal
    memoriaLivreBytesGauge.Set(memoriaLivre())                        // setando o valor da métrica de memória livre em bytes
    memoriaLivreMegabytesGauge.Set(memoriaLivre() / 1024 / 1024)      // setando o valor da métrica de memória livre em megabytes
    totalMemoryBytesGauge.Set(totalMemory())                          // setando o valor da métrica de memória total em bytes
    totalMemoryGigaBytesGauge.Set(totalMemory() / 1024 / 1024 / 1024) // setando o valor da métrica de memória total em gigabytes

    http.Handle("/metrics", promhttp.Handler()) // criando o servidor web para expor as métricas

    log.Fatal(http.ListenAndServe(":7788", nil)) // iniciando o servidor web na porta 7788
}
```

&nbsp;

#### Installing the libraries to run exporter

Remember that we are using the `prometheus` package to create our exporter and `promhttp` to expose the metrics through a web server.
We are also using the `memory` package to get the memory information from our server.

We are using the `log` package to log any errors that may occur and the `net/http` package to create the webserver.

&nbsp;

Before running the exporter we need to install the libraries used in the code.

```BASH
go mod init second-exporter
go mod tidy
```

&nbsp;

Now we can compile the code as shown in the example below.

```BASH
go build segundo-exporter.go
```

&nbsp;

Note that the command generated a Go binary called `second-exporter`, let's run it

```BASH
./second-exporter
```

&nbsp;

#### Checking metrics

We can check the metrics by accessing the URL `http://localhost:7788/metrics`

You can also check the metrics using the `curl` command as shown below

```BASH
curl http://localhost:7788/metrics
```

&nbsp;
&nbsp;

### New container for second exporter

#### Creating a container image with the exporter in Go

Let's add our `Golang exporter` to a `container`, we will create a file called `Dockerfile` in the `second-exporter` file with the following content:

```DOCKERFILE
FROM golang:1.22.5-alpine3.20 AS construindo

WORKDIR /app
COPY . /app/

RUN go build second-exporter.go

FROM alpine:3.20
LABEL maintainer Ernane <ernane@email.com.br>
LABEL description "Executando o nosso segundo exporter"
COPY --from=construindo /app/second-exporter /app/second-exporter
EXPOSE 7788
WORKDIR /app
CMD ["./second-exporter"]
```

&nbsp;

Now let's `build` the image of our `exporter`, to do this we run the following command.

```BASH
docker build -t second-exporter:1.0 .
```

&nbsp;

Let's list the new `container` image with the `exporter`.

```BASH
docker images | grep second-exporter
```

&nbsp;

Okay, it's there, now run the `exporter`.

```BASH
docker run -d --name second-exporter -p 7788:7788 second-exporter:1.0
```

&nbsp;

Now let's list our running `containers`.

```BASH
docker ps
```

&nbsp;

Let's access the metrics with following command.

```BASH
curl http://localhost:7788/metrics
```

&nbsp;
&nbsp;

#### Configuring Prometheus for new Target

Accessing `prometheus.yml` file and adding the following content.

```YML
- job_name: 'segundo-exporter'
  static_configs:
    - targets: ['localhost:7788']
```

&nbsp;

The final version of the file will look like the model below.

```YML
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "Meu Primeiro Exporter"
    static_configs:
      - targets: ["localhost:8899"]
  
  - job_name: 'segundo-exporter'
    static_configs:
      - targets: ['localhost:7788']
```

&nbsp;

Restart `Prometheus` to load the new settings.

```BASH
systemctl restart prometheus
```

&nbsp;

You can also do this via `kill` command.

```BASH
kill -HUP $(pidof prometheus)
```

&nbsp;

Access `Prometheus` via `browser` and check if the new `target` with the new `metrics` is there.

```
http://localhost:9090
```

&nbsp;

Check metrics via `terminal`.

```BASH
curl http://localhost:7788/metrics
```

&nbsp;
&nbsp;



&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;

