# Prometheus installation

# copy the Prometheus file link from the tool's official website
# "https://prometheus.io/download/"
# after copying the link corresponding to the system, run the following command in the terminal
$ sudo curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz

# if "curl" is not installed, update the system and then run the install command
$ sudo apt update && sudo apt upgrade
$ sudo apt install curl
# then repeat the first command in the file

# now extract the file with the following command
$ tar -xvzf prometheus-2.51.1.linux-amd64.tar.gz

# move the "prometheus" and "promtool" files to "/usr/local/bin" with the following commands
$ sudo mv prometheus-2.51.1.linux-amd64/prometheus /usr/local/bin
$ sudo mv prometheus-2.51.1.linux-amd64/promtool /usr/local/bin

# create a directory named prometheus in the "/etc/" and "/var/lib/" directories
$ sudo mkdir /etc/prometheus
$ sudo mkdir /var/lib/prometheus

# copy the file "prometheus.yml" to "/etc/prometheus/"
$ sudo cp prometheus-2.51.1.linux-amd64/prometheus.yml /etc/prometheus/

# move "consoles" and "console_libraries" to "/etc/prometheus/"
$ sudo mv prometheus-2.51.1.linux-amd64/consoles /etc/prometheus/
$ sudo mv prometheus-2.51.1.linux-amd64/console_libraries /etc/prometheus/

# create a user and add to a group exclusive to "Prometheus"
$ sudo addgroup --system prometheus
$ sudo adduser --shell /sbin/nologin --system --group prometheus

# create the "Prometheus" service and add the page content "https://github.com/ernanecl/linuxtips/blob/main/DescomplicandoPrometheus/day-1/prometheus.service"
$ sudo vim /etc/systemd/system/prometheus.service

# use the "chown" command to change the owner and group of "Prometheus" files and directories on "Linux"
$ sudo chown -R prometheus:prometheus /var/log/prometheus
$ sudo chown -R prometheus:prometheus /etc/prometheus/
$ sudo chown -R prometheus:prometheus /var/lib/prometheus/
$ sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
$ sudo chown -R prometheus:prometheus /usr/local/bin/promtool

# run reload of "systemctl daemon" to reload the "systemd" manager configuration
$ sudo systemctl daemon-reload

# start and check status of "Prometheus"
$ sudo systemctl start prometheus
$ sudo systemctl status prometheus

# configuring Prometheus for automatic system startup
$sudo systemctl enable prometheus

# check if everything is ok in the logs
$ sudo journalctl -u prometheus

# access Prometheus graphical interface and metrics through the browser
http://localhost:9090
http://localhost:9090/metrics
