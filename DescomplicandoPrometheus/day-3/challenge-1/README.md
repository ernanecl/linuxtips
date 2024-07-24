### Challenge 1 - Do some troubleshooting to get the Golang exporter working again

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
sudo tar -C /usr/local -xvf go1.12.6.linux-amd64.tar.gz
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

&nbsp;
&nbsp;

#### Setting up the environment

Before running the exporter we need to install the libraries used in the code.

```BASH
go mod init segundo-exporter
go mod tidy
```

&nbsp;

Now we can compile the code as shown in the example below.

```BASH
go build segundo-exporter.go
```

&nbsp;

Note that the command generated a Go binary called `segundo-exporter`, let's run it

```BASH
./segundo-exporter
```

&nbsp;
&nbsp;

Creating a container image with the `exporter` in `Go`.

Let's add `Golang exporter` to a `container`, for that we have to access the `Dockerfile` file and check if it follows the model below.

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