# Prometheus's First Steps

## Download and run Prometheus without installation

Access the `official Prometheus website`.

```https://prometheus.io/download/```

&nbsp;

After accessing the `download link`, copy the link corresponding to the `system` and execute the following command in the `terminal`:

```BASH
sudo curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz
```

&nbsp;

If `curl` is not installed, update the `system` and then run the install command:

```BASH
sudo apt update && sudo apt upgrade
```

```BASH
sudo apt install curl
```

Then repeat the `curl` command.

&nbsp;

Now `extract` the file with the following command:

```BASH
tar -xvzf prometheus-2.51.1.linux-amd64.tar.gz
```

&nbsp;

Check the Prometheus version with the command below:

```BASH
./prometheus --version
```

Remembering that to execute the `command` exactly as above, you need to be inside the folder that was extracted or execute the full path to `Prometheus`.

&nbsp;

To `test Prometheus without installing` it, run the following command:

```BASH
sudo ./prometheus
```

&nbsp;

To check the `Prometheus process`, run the following command:

```BASH
ps -ef | grep prometheus
```

To finish running `Prometheus`, run the command below:

```BASH
sudo kill -9 38104
```

The numbering of the command above is the same as that which appears in the `Prometheus` process command.

&nbsp;
&nbsp;



## Prometheus installation

To prepare the `system` to run `Prometheus` as a `service`, we will work with the `file extracted` in the previous step.

Move the `prometheus` and `promtool` files to `/usr/local/bin` with the following commands:

```BASH
sudo mv prometheus-2.51.1.linux-amd64/prometheus /usr/local/bin
```

```BASH
sudo mv prometheus-2.51.1.linux-amd64/promtool /usr/local/bin
```

These files are `Prometheus` binaries, moving them allows `Prometheus` to run without having to use the `./` command.

&nbsp;

create a configuration directory called `prometheus` in the path `/etc/` and copy the `prometheus.yml` file to `/etc/prometheus/`.

```BASH
sudo mkdir /etc/prometheus
```

```BASH
sudo cp prometheus-2.51.1.linux-amd64/prometheus.yml /etc/prometheus/
```

&nbsp;

Inside the `file` add the following content:

```YML
global:
    scrape_interval: 15s
    evaluation_interval: 15s
    scrape_timeout: 10s

rule_files:

scrape_configs:
    - job_name: "prometheus"
      static_configs: 
        - targets: ["localhost:9090"]
```

&nbsp;

Move `consoles` and `console_libraries` to `/etc/prometheus/`.

```BASH
sudo mv prometheus-2.51.1.linux-amd64/consoles /etc/prometheus/ && sudo mv prometheus-2.51.1.linux-amd64/console_libraries /etc/prometheus/
```

&nbsp;

Needs a `directory to store the data` that `Prometheus` is generating, create a directory called `prometheus` in the path `/var/lib/`.

```BASH
sudo mkdir /var/lib/prometheus
```

&nbsp;

If you need to remove everything from `Prometheus`, run the command below:

```BASH
sudo rm -rf /var/lib/prometheus
```

&nbsp;

To run `Prometheus as a service` and not make the `root user responsible` for `running the service`, create a `user` and add to a `group` exclusive to `Prometheus`.

```BASH
sudo addgroup --system prometheus
```

```BASH
sudo adduser --shell /sbin/nologin --system --group prometheus
```

&nbsp;

If you need to `delete a user`, use the following command:

```BASH
sudo deluser prometheus
```

&nbsp;

To create `Prometheus` as a service on `Linux`, `systemd` manages the services within the `system`.

To do this create a file called `prometheus.service`, it is a service unit that tells `systemd` how to start `Prometheus`.

```BASH
sudo vim /etc/systemd/system/prometheus.service
```

&nbsp;

Inside the `file` add the following content:

```SERVICE
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
```

&nbsp;

Link to original content: 

```https://github.com/badtuxx/DescomplicandoPrometheus/blob/main/pt/src/day-1/files/prometheus.service```

&nbsp;

Now let's change the `owner and group of Prometheus`.

Use the `chown` command to change the owner and group of `Prometheus` files and directories on `Linux`.

```BASH
sudo chown -R prometheus:prometheus /var/log/prometheus
```

```BASH
sudo chown -R prometheus:prometheus /etc/prometheus
```

```BASH
sudo chown -R prometheus:prometheus /var/lib/prometheus
```

```BASH
sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
```

```BASH
sudo chown -R prometheus:prometheus /usr/local/bin/promtool
```

&nbsp;

Single command to perform owner and group change.

```BASH
sudo chown -R prometheus:prometheus /etc/prometheus && sudo chown -R prometheus:prometheus /var/lib/prometheus && sudo chown -R prometheus:prometheus /usr/local/bin/prometheus && sudo chown -R prometheus:prometheus /usr/local/bin/promtool
```

&nbsp;

Reload `systemctl daemon` to load the configuration from the `systemd` manager.

```BASH
sudo systemctl daemon-reload
```

&nbsp;

Start and check the status of `Prometheus`.

```BASH
sudo systemctl start prometheus
```

&nbsp;

```BASH
sudo systemctl status prometheus
```

&nbsp;

Configuring `Prometheus` for `automatic system` startup.

```BASH
sudo systemctl enable prometheus
```

&nbsp;

To check if everything is ok in the `logs`.

```BASH
sudo journalctl -u prometheus
```

&nbsp;

To access the `metrics` via the `terminal`, use the command below:

```BASH
curl http://localhost:9090/metrics
```

&nbsp;

Access `Prometheus graphical` interface and metrics through the `browser`.

```http://localhost:9090```

```http://localhost:9090/metrics```

&nbsp;

To test a `query` through the `browser`, you can use the following example below:

```BASH
process_cpu_seconds_total{job="prometheus"}[2m]
```