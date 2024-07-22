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