### Challenge 1 - Do some troubleshooting to get the Golang exporter working again

#### External materials

```
https://go.dev/dl/
```

```
https://linuxcapable.com/pt/como-instalar-golang-go-no-debian-linux/
```

```
https://pt.linux-console.net/?p=12240#:~:text=Abra%20um%20terminal%20e%20execute%20o%20seguinte%20comando,-Syu%20No%20RHEL%20e%20Fedora%3A%20sudo%20dnf%20upgrade
```

#### Checking services and installing Golang manually

The services that need to be checked if they are installed are `Prometheus`, `Golang` and `Docker`.

```BASH
prometheus --version
docker --version
go version
```

&nbsp;

By checking all the above services, only `Golang` is not installed.

To manually install `Go` on your `Linux` machine, you will first need to get the latest `Go TAR` package from the official `Golang` website. You can do this manually or by using the wget command on `Linux`:

```BASH
wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
```

&nbsp;

Download: [Go (Linux)](https://go.dev/dl/)

Now you need to unpack the package into the recommended default `directory` (you can change this to your preference) using a `tar` command prefixed with sudo `tag -xvf`:

```BASH
sudo tar -C /usr/local -xvf go1.22.5.linux-amd64.tar.gz
```

&nbsp;

Next, add the directory where you unpacked the package to your `PATH environment variable`. You can do this using the export command:

```BASH
export PATH=$PATH:/usr/local/go/bin
```

&nbsp;

These are all the steps required to manually install `Go`. You can verify the installation by running the following command:

```BASH
go version
```

Now we can compile the code as shown in the example below to generate a `Go binary` called `second-exporter`.

```BASH
go build segundo-exporter.go
```

```BASH
./segundo-exporter
```

&nbsp;
&nbsp;

#### Fixing files

Adjusting the `prometheus.yml` file

```YML
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
  
  - job_name: 'segundo-exporter'
    static_configs:
      - targets: ['localhost:7788']
```

&nbsp;

Let's validate if the `Dockerfile` file is correct according to the model below.

```DOCKERFILE
FROM golang:1.22.5-alpine3.20 AS construindo

WORKDIR /app
COPY . /app/

RUN go build segundo-exporter.go

FROM alpine:3.20
LABEL maintainer Ernane <ernane@email.com.br>
LABEL description "Executando o nosso segundo exporter"
COPY --from=construindo /app/segundo-exporter /app/segundo-exporter
EXPOSE 7788
WORKDIR /app
CMD ["./segundo-exporter"]
```

&nbsp;



&nbsp;
&nbsp;

#### Creating a container image for `exporter` in `Go`

Now let's `build` the image of our `exporter`, to do this we run the following command.

```BASH
docker build -t segundo-exporter:1.0 .
```

&nbsp;

Let's list the new `container image` with the `exporter`.

```BASH
docker images | grep segundo-exporter
```

&nbsp;

Okay, it's there, now run the exporter.

```BASH
docker run -d --name segundo-exporter -p 7788:7788 segundo-exporter:1.0
```

&nbsp;

Now let's list our running containers.

```BASH
docker ps
```

&nbsp;

Let's access the metrics with following command.

```BASH
curl http://localhost:7788/metrics
```
