## Extra content

### Create a second exporter in Go

You need to install the `Go` package, to install `Go` on `Debian`, just run the following command.

```BASH
sudo apt install golang
```
&nbsp;

### Creating the exporter using Go

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

Now we can compile the code as shown in the example below.

```BASH
go build segundo-exporter.go
```

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