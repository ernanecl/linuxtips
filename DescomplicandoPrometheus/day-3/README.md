## Content

### Creating and configuring new exporter using Golang

You need to install the `Go` package, to install `Go` on `Debian`, just run the following command:

```BASH
sudo apt install golang
```
&nbsp;

Creating the exporter using `Go`.

Let's create a file called `second-exporter.go` in `second-exporter directory`.

And let's add the following code:

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

Installing the `libraries` to run `exporter`.

Remember that we are using the `prometheus` package to create our exporter and `promhttp` to expose the metrics through a web server.

We are also using the `memory` package to get the memory information from our server.

We are using the `log` package to log any errors that may occur and the `net/http` package to create the webserver.

&nbsp;

Before running the `exporter` we need to install the `libraries` used in the code:

```BASH
go mod init second-exporter
go mod tidy
```

&nbsp;

Now we can compile the code as shown in the example below:

```BASH
go build segundo-exporter.go
```

&nbsp;

Note that the command generated a Go binary called `second-exporter`, let's run it:

```BASH
./second-exporter
```

&nbsp;

Checking `metrics`.

We can check the metrics by accessing the URL `http://localhost:7788/metrics`.

You can also check the metrics using the `curl` command as shown below:

```BASH
curl http://localhost:7788/metrics
```

&nbsp;
&nbsp;

### New container for second exporter

Creating a container image with the `exporter` in `Go`.

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

Now let's `build` the image of our `exporter`, to do this we run the following command:

```BASH
docker build -t second-exporter:1.0 .
```

&nbsp;

Let's list the new `container` image with the `exporter`.

```BASH
docker images | grep second-exporter
```

&nbsp;

Okay, now run `exporter` on the container.

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

### Configuring Prometheus for new Target

Accessing `prometheus.yml` file and adding the following content:

```YML
- job_name: 'segundo-exporter'
  static_configs:
    - targets: ['localhost:7788']
```

&nbsp;

The final version of the file will look like the model below:

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

### Rate and irate functions

The `rate` function represents the growth rate per second of a given metric as an `average`, over a time interval.

&nbsp;

```PROMQL
rate(metrica)[5m]
```

Where `metrica` is the metric you want to calculate the growth rate for over a 5-minute time interval. You can use the rate function to work with metrics of the `gauge` and `counter` type.

&nbsp;

Let's look at a real example:

```PROMQL
rate(prometheus_http_requests_total{job="prometheus",handler="/api/v1/query"}[5m])
```

Here we are calculating the average growth rate per second of the metric `prometheus_http_requests_total`, filtering by `job` and `handler` over a 5-minute time interval.

In this case I want to know the growth in `queries` that are being made in `Prometheus`.

&nbsp;

The `irate` function represents the growth rate per second of a given metric, but unlike the `rate` function, the `irate` function does not average the values, it takes the last two points and calculates the growth rate.

When represented in a graph, it is possible to see the difference between the `rate` function and the `irate` function, while the graph with the `rate` is smoother, the graph with the `irate` is more "spiky", you can see sharper drops and rises.

&nbsp;

```PROMQL
irate(metrica)[5m]
```

Where `metrica` is the metric for which you want to calculate the growth rate, considering only the last two points, during a time interval of 5 minutes.

&nbsp;

Let's look at a real example:

```PROMQL
irate(prometheus_http_requests_total{job="prometheus",handler="/api/v1/query"}[5m])
```

Here I'm calculating the growth rate per second of the metric `prometheus_http_requests_total`, considering only the last two points, filtering by `job` and `handler` and during a time interval of 5 minutes.

In this case I want to know the growth in the `queries` that are being made in `Prometheus`.

&nbsp; 
&nbsp;

### Delta and increase functions

The `delta` function represents the difference between the current value and the previous value of a metric.

When we talk about `delta` we are talking about, for example, the consumption of a `disk`.

Let's imagine that I want to know how much `disk` I used in a certain time interval, I can use the `delta` function to calculate the difference between the current value and the previous value.

&nbsp;

```PROMQL
delta(metrica[5m])
```

Where metric is the metric for which you want to calculate the difference between the current value and the previous value, during a time interval of 5 minutes.

&nbsp;

Let's look at a real example:

```PROMQL
delta(prometheus_http_response_size_bytes_count{job="prometheus",handler="/api/v1/query"}[5m])
```

Now I'm calculating the difference between the current value and the previous value of the metric `prometheus_http_response_size_bytes_count`, filtering by `job` and `handler` during a time interval of 5 minutes.

In this case I want to know how many `bytes` I'm consuming in the `queries` that are being made in `Prometheus`.

&nbsp;

The `increase` function, like the `delta` function, represents the difference between the first and last values ​​during a time interval. However, the difference is that the `increase` function considers the value to be a counter, that is, the value is incremented each time the metric is updated.

It starts with the value 0 and adds the value of the metric with each update. You can already imagine what type of metric it works with, right? Counter!

&nbsp;

```PROMQL
increase(metrica[5m])
```

Where `metrica` is the metric for which you want to calculate the difference between the first and last values ​​during a time interval of 5 minutes.

&nbsp;

Let's look at a real example:

```PROMQL
increase(prometheus_http_requests_total{job="prometheus",handler="/api/v1/query"}[5m])
```

Here we are calculating the difference between the first and last values ​​of the `prometheus_http_requests_total` metric, filtering by `job` and `handler` during a 5-minute time interval.

You can follow the result of this `query` by clicking on `Graph` and then on `Execute`, so you will see the graph with the result of the `query` making more sense.

&nbsp;
&nbsp;

### Sum and count functions

The `sum` function represents the sum of all the values ​​of a metric.

You can use the `sum` function on the `counter`, `gauge`, `histogram` and `summary` data types.

An example of using the `sum` function is when you want to know how much `memory` is being used by all of your `containers`, or how much memory is being used by all of your `pods`.

```PROMQL
sum(metrica)
```

Where `metrica` is the metric you want to sum.

&nbsp;

Let's look at a real-world example:

```PROMQL
sum(go_memstats_alloc_bytes{job="prometheus"})
```

Here I'm summing all the values ​​of the `go_memstats_alloc_bytes` metric, filtering by `job` over a 5-minute time range.

&nbsp;

The `count` function is another widely used function, it represents the counter of a metric.

You can use the `count` function on the `counter`, `gauge`, `histogram` and `summary` data types.

An example of using the `count` function is when you want to know how many `containers` are running at a given time or how many `pods` are running.

&nbsp;

```PROMQL
count(metrica)
```

Where metric is the metric you want to count.

&nbsp;

Let's look at a real example:

```PROMQL
count(prometheus_http_requests_total)
```

We will have as a result the number of values ​​that the metric `prometheus_http_requests_total` has.

&nbsp;
&nbsp;

### avg, min and max functions

The `avg` function represents the average value of a metric.

You can use the `avg` function in the `counter`, `gauge`, `histogram` and `summary` data types.

This is one of the most used functions, as it is very common to want to know the average value of a metric, for example, the average value of `memory` used by a `container`.

&nbsp;

```PROMQL
avg(metrica)
```

Where `metrica` is the metric you want to calculate the average of.

&nbsp;

The `min` function represents the minimum value of a metric.

You can use the `min` function in the `counter`, `gauge`, `histogram` and `summary` data types.

An example of using the `min` function is when you want to know the lowest value of `memory` used by a `container`.

```PROMQL
min(metric)
```

Where metric is the metric you want to calculate the minimum of.

&nbsp;

The `max` function represents the maximum value of a metric.

An example of using the `max` function is when you want to know the maximum memory value for the nodes of a Kubernetes cluster.

&nbsp;

```PROMQL
max(metric)
```

Where `metric` is the metric you want to calculate the maximum of.

&nbsp;
&nbsp;

### avg_over_time, sum_over_time, min_over_time, max_over_time and stddev_over_time functions

The ```avg_over_time``` function represents the `average` of a metric over a period of time.

Typically used to calculate the `average` of a metric over a period of time, such as the average number of requests per second over a period of time or the number of people in the space over the last year.

&nbsp;

```PROMQL
avg_over_time(metrica[5m])
```

Where `metrica` is the metric you want to average over a 5-minute period of time.

&nbsp;

Let's look at a real example:

```PROMQL
avg_over_time(prometheus_http_requests_total{handler="/api/v1/query"}[5m])
```

Now I'm calculating the `average` of the metric `prometheus_http_requests_total`, filtering by `handler` over a 5-minute time interval.

&nbsp;

The `sum_over_time` function represents the sum of a metric over a time interval.

We saw `avg_over_time` which represents the average, `sum_over_time` represents the sum of the values ​​over a time interval.

Imagine calculating the `sum` of a metric over a time interval, such as the `sum` of requests per second over a time interval or the sum of people who have been in the space over the last year.

&nbsp;

```PROMQL
sum_over_time(metrica[5m])
```

Where `metrica` is the metric you want to calculate the `sum` over a 5 minute time interval.

&nbsp;

Let's go to a real example:

```PROMQL
sum_over_time(prometheus_http_requests_total{handler="/api/v1/query"}[5m])
```

Now I'm calculating the `sum` of the metric `prometheus_http_requests_total`, filtering by `handler` over a 5 minute time interval.

&nbsp;

The `max_over_time` function represents the `maximum` value of a metric over a time interval.

&nbsp;

```PROMQL
max_over_time(metrica[5m])
```

Where `metrica` is the metric you want to calculate the `maximum` value over a 5 minute time interval.

&nbsp;

Let's go to a real example:

```PROMQL
max_over_time(prometheus_http_requests_total{handler="/api/v1/query"}[5m])
```

Now we are looking for the `maximum` value of the metric `prometheus_http_requests_total`, filtering by `handler` over a 5 minute time interval.

&nbsp;

The `min_over_time` function represents the minimum value of a metric over a time interval.

&nbsp;

```PROMQL
min_over_time(metrica[5m])
```

Where `metrica` is the metric you want to calculate the `minimum` value for during a 5-minute time interval.

&nbsp;

Let's go to a real example:

```PROMQL
min_over_time(prometheus_http_requests_total{handler="/api/v1/query"}[5m])
```

Now we are looking for the `minimum` value of the `prometheus_http_requests_total` metric, filtering by `handler` during a 5-minute time interval.

&nbsp;

The `stddev_over_time` function represents the standard deviation, which are the values ​​that are furthest from the mean, of a metric during a time interval.

A good example would be to calculate the standard deviation to find out if there was any anomaly in disk consumption, for example.

&nbsp;

```PROMQL
stddev_over_time(metrica[5m])
```

Where `metrica` is the metric for which you want to calculate the standard deviation during a 5-minute time interval.

&nbsp;

Let's look at a real example:

```PROMQL
stddev_over_time(prometheus_http_requests_total{handler="/api/v1/query"}[10m])
```

Now we are looking for the standard deviations of the metric `prometheus_http_requests_total`, filtering by `handler` during a 10-minute time interval.

It is worth checking the graph, as it makes it easier to visualize the values.

&nbsp;
&nbsp;

### Functions by and without

The `by` function is used to group metrics. With it, it is possible to group metrics by `labels`, for example, if I want to group all metrics that have the `job` label, I can use the `by` function as follows:

```PROMQL
sum(metrica) by (job)
```

&nbsp;

Where `metrica` is the metric you want to group and `job` is the `label` you want to group.

&nbsp;

Let's look at a real example:

```PROMQL
sum(prometheus_http_requests_total) by (code)
```

Now we are adding the `prometheus_http_requests_total` metric and grouping by `code`, so we know how many requests were made by response code.

&nbsp;

The without function is used to remove labels from a metric. You can use the without function on the `counter`, `gauge`, `histogram` and `summary` data types, often used in conjunction with the sum function.

For example, if I want to remove the `job` label from a metric, I can use the `without` function as follows:

```PROMQL
sum(metrica) without (job)
```

Where `metrica` is the metric you want to remove the `job` label from.

&nbsp;

Let's look at a real example:

```PROMQL
sum(prometheus_http_requests_total) without (handler)
```

Now we are summing the `prometheus_http_requests_total` metric and removing the `label handler`, so we know how many requests were made by response code, without knowing which `handler` was used to have a more general view and focused on the response code.


&nbsp;

### Quantile and histogram_quantile functions

The `histogram_quantile` and `quantile` functions are very similar, but `histogram_quantile` is used to calculate the `percentile` of a `histogram` type metric and `quantile` is used to calculate the `percentile` of a `summary` type metric.

Basically, we use these functions to find out what the value of a metric is at a given `percentile`.

&nbsp;

```PROMQL
quantile(0.95, metric)
```

Where `metric` is the `histogram` type metric for which you want to calculate the `percentile` and 0.95 is the `percentile` you want to calculate.

&nbsp;

Let's look at a real example:

```PROMQL
quantile(0.95, prometheus_http_request_duration_seconds_bucket)
```

Now we are calculating the 95% percentile of the `prometheus_http_request_duration_seconds_bucket` metric, so we know what the response time is for 95% of the requests.

&nbsp;
&nbsp;

### Simplifying Node Exporter

`Node Exporter` allows you to collect `metrics` from `Linux` or `macOS` computers, such as `CPU usage`, `disk usage`, `memory usage`, `open files`, etc.

`Node Exporter` is an `open source` project written in `Go`. Running on `Linux` as a service, it collects and exposes operating system metrics.


&nbsp;

`Node Exporter` has `collectors` that are responsible for capturing operating system `metrics`. By default, `Node Exporter` comes with a bunch of `collectors` enabled, but you can enable others if you want.

To see the list of `collectors` that are `enabled by default`, you can access the link below:

[Collectors enabled by default](https://github.com/prometheus/node_exporter#enabled-by-default)

There is also a list of `collectors` that are `disabled by default`:

[Collectors disabled by default](https://github.com/prometheus/node_exporter#disabled-by-default)

&nbsp;

Below are some useful `collectors` commented on:

```
arp: Coleta métricas de ARP (Address Resolution Protocol) como por exemplo, o número de entradas ARP, o número de resoluções ARP, etc.
bonding: Coleta métricas de interfaces em modo bonding.
conntrack: Coleta métricas de conexões via Netfilter como por exemplo, o número de conexões ativas, o número de conexões que estão sendo rastreadas, etc.
cpu: Coleta métricas de CPU.
diskstats: Coleta métricas de IO de disco como por exemplo o número de leituras e escritas.
filefd: Coleta métricas de arquivos abertos.
filesystem: Coleta métricas de sistema de arquivos, como tamanho, uso, etc.
hwmon: Coleta métricas de hardware como por exemplo a temperatura.
ipvs: Coleta métricas de IPVS.
loadavg: Coleta métricas de carga do sistema operacional.
mdadm: Coleta métricas de RAID como por exemplo o número de discos ativos.
meminfo: Coleta métricas de memória como por exemplo o uso de memória, o número de buffers, caches, etc.
netdev: Coleta métricas de rede como por exemplo o número de pacotes recebidos e enviados.
netstat: Coleta métricas de rede como por exemplo o número de conexões TCP e UDP.
os: Coleta métricas de sistema operacional.
selinux: Coleta métricas de SELinux como estado e políticas.
sockstat: Coleta métricas de sockets.
stat: Coleta métricas de sistema como uptime, forks, etc.
time: Coleta métricas de tempo como sincronização de relógio.
uname: Coleta métricas de informações.
vmstat: Coleta métricas de memória virtual.
```

&nbsp;
&nbsp;

Intalling `Node Exporter` on `Linux`

The `Node Exporter` is a `binary` file that we need to download from the project's official website.

Below is the `URL` to download the `Node Exporter`:

```
https://prometheus.io/download/#node_exporter
```

Access the URL and see which is the latest version available for download.

Let's download the `Node Exporter` binary file:

```BASH
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
```

&nbsp;

With the file already on our machine, let's unpack it:

```BASH
tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz
```

&nbsp;

Since `Node Exporter` is just a `Go` binary, so it's very simple to install it on a `Linux` machine. Basically, we'll follow the same process we did to install `Prometheus`.

Move the `node_exporter` file to the `/usr/local/bin` directory:

```BASH
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
```

&nbsp;

Check the Node Exporter version:

```BASH
node_exporter --version
```

&nbsp;

Let's create the `node_exporter` user to be responsible for running the service:

```BASH
sudo addgroup --system node_exporter
sudo adduser --shell /sbin/nologin --system --group node_exporter
```

&nbsp;

Now let's create the `Node Exporter` service configuration file for `Systemd`:

```BASH
sudo vim /etc/systemd/system/node_exporter.service
```

Let's add the following content:

```BASH
[Unit] # Start of the service configuration file
Description=Node Exporter # Description of the service
Wants=network-online.target # Defines that the service depends on the network to start
After=network-online.target # Defines that the service should be started after the network is available

[Service] # Defines the service settings
User=node_exporter # Defines the user that will run the service
Group=node_exporter # Defines the group that will run the service
Type=simple # Defines the service type
ExecStart=/usr/local/bin/node_exporter # Defines the path to the service binary

[Install] # Defines the service installation settings
WantedBy=multi-user.target # Defines that the service will be started using the multi-user target
```

Important: Don't forget to remove the comments from the service configuration file.

&nbsp;

Every time we add a new service in `Systemd`, we need to restart it so that the service is recognized:

```BASH
sudo systemctl daemon-reload
```

&nbsp;

Now let's start the service:

```BASH
sudo systemctl start node_exporter
```

&nbsp;

We need to check if everything is ok with the service:

```BASH
sudo systemctl status node_exporter
```

&nbsp;

The `Node Exporter` is running successfully, now let's enable the service so that it starts every time the server is restarted:

```BASH
sudo systemctl enable node_exporter
```

It is important to mention that the `Node Exporter` runs on port `9100`. To access the metrics collected by the `Node Exporter`, simply access the URL `http://<MACHINE_IP>:9100/metrics`.

&nbsp;

To check if `Node Exporter` is using port `9100`, we have the `ss` command that allows us to see the `TCP` and `UDP` connections that are open on our machine.

Let's use this command to see if `Node Exporter` is listening on port `9100`:

```BASH
ss -atunp | grep 9100
```

&nbsp;

Now let's see the metrics collected by it:

```BASH
curl http://localhost:9100/metrics
```

Remember to change `localhost` to the `IP` of your machine, if you installed it on another machine.

&nbsp;

Adding `Node Exporter` to `Prometheus`

Remember that these metrics are not yet in `Prometheus`.

In order for them to be there, we need to configure `Prometheus` to collect the metrics from `Node Exporter`, that is, configure `Prometheus` to `scrape` the `Node Exporter`.

&nbsp;

To do this, we need to create another job in the `Prometheus` configuration file to define our new `target`.

Let's add the following content to the `Prometheus` configuration file:

```YML
  - job_name: 'node_exporter'
	static_configs:
	  - targets: ['localhost:9100']
```

Important: Remember again to change `localhost` to the `IP` of your machine, if you installed it on another machine.

&nbsp;

The file should look like this:

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

  - job_name: 'node_exporter'
	static_configs:
	  - targets: ['localhost:9100']
```

&nbsp;

Now let's restart `Prometheus` so it can read the new configurations:

```BASH
sudo systemctl restart prometheus
```

&nbsp;

Let's see if the new job was successfully created:

```BASH
curl http://localhost:9090/targets
```

&nbsp;

To see the new `target` via the `Prometheus` web interface, just access the URL `http://localhost:9090/targets`.

&nbsp;

`Prometheus Targets`

Now let's see if `Prometheus` is collecting the metrics from `Node Exporter`.

Let's pass the `job` name to `Prometheus`, so the `query` will be even more specific:

```BASH
curl -GET http://localhost:9090/api/v1/query --data-urlencode "query=node_cpu_seconds_total{job='node_exporter'}" | jq .
```