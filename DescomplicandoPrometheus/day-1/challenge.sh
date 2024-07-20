# Prometheus installation

# access the official Prometheus website
# "https://prometheus.io/download/"
# after accessing, copy the link corresponding to the system and execute the following command in the terminal
$ sudo curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz

# if "curl" is not installed, update the system and then run the install command
$ sudo apt update && sudo apt upgrade
$ sudo apt install curl
# then repeat the first command in the file

# now extract the file with the following command
$ tar -xvzf prometheus-2.51.1.linux-amd64.tar.gz

# check version prometheus
$ ./prometheus --version

# move the "prometheus" and "promtool" files to "/usr/local/bin" with the following commands (binaries)
# moving the binaries is possible to run Prometheus without the need to use the ./ command
$ sudo mv prometheus-2.51.1.linux-amd64/prometheus /usr/local/bin
$ sudo mv prometheus-2.51.1.linux-amd64/promtool /usr/local/bin

# create a configuration directory called prometheus in the following path "/etc/"
# copy the file "prometheus.yml" to "/etc/prometheus/"
$ sudo mkdir /etc/prometheus
$ sudo cp prometheus-2.51.1.linux-amd64/prometheus.yml /etc/prometheus/

# move "consoles" and "console_libraries" to "/etc/prometheus/"
$ sudo mv prometheus-2.51.1.linux-amd64/consoles /etc/prometheus/
$ sudo mv prometheus-2.51.1.linux-amd64/console_libraries /etc/prometheus/

# needs a directory to store the data that Prometheus is generating
# create directory called prometheus in the following path "/var/lib/"
$ sudo mkdir /var/lib/prometheus

# to run Prometheus as a service and not make the root user responsible for running the service
# create a user and add to a group exclusive to Prometheus
$ sudo addgroup --system prometheus
$ sudo adduser --shell /sbin/nologin --system --group prometheus

# you need to create Prometheus as a service, in Linux, systemd manages the service
# to do this, you need to create a service unit, it is a file that tells systemd how it should start Prometheus
# create a file named prometheus.service
$ sudo vim /etc/systemd/system/prometheus.service

# inside the file add the following content:
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

# content original: https://github.com/badtuxx/DescomplicandoPrometheus/blob/main/pt/src/day-1/files/prometheus.service
# you can also consult the content on the page "https://github.com/ernanecl/linuxtips/blob/main/DescomplicandoPrometheus/day-1/prometheus.service"

# use the "chown" command to change the owner and group of "Prometheus" files and directories on "Linux"
$ sudo chown -R prometheus:prometheus /var/log/prometheus
$ sudo chown -R prometheus:prometheus /etc/prometheus
$ sudo chown -R prometheus:prometheus /var/lib/prometheus
$ sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
$ sudo chown -R prometheus:prometheus /usr/local/bin/promtool

# reload "systemctl daemon" to reload the "systemd" manager configuration
$ sudo systemctl daemon-reload

# start and check status of "Prometheus"
$ sudo systemctl start prometheus
$ sudo systemctl status prometheus

# configuring Prometheus for automatic system startup
$ sudo systemctl enable prometheus

# check if everything is ok in the logs
$ sudo journalctl -u prometheus

# access Prometheus graphical interface and metrics through the browser
http://localhost:9090
http://localhost:9090/metrics
