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
    curl -GET localhost:9090/api/v1/query --data-urlencode "query=up" | jq .

To use the "jq" command we need to install it
to install it use the following command
    apt install jq -y

Data model - Prometheus
    metric {label_name="label_value"}   value

    Exemple
        up {instance="localhost:9090", job="prometheus"}   1

### Exporter
Open Notify: open-notify.org/Open-Notify-API/People-In-Space

### Queries