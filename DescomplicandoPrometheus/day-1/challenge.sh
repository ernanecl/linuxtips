# Prometheus installation
# copy the Prometheus file link from the tool's official website
# <https://prometheus.io/download/>
# after copying the link corresponding to the system, run the following command in the terminal
$ sudo curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz

# if <curl> is not installed, update the system and then run the install command
$ sudo apt update && sudo apt upgrade
$ sudo apt install curl
# then repeat the first command in the file

# now extract the file with the following command
$ tar -xvzf prometheus-2.51.1.linux-amd64.tar.gz

# move the <prometheus> and <promtool> files to </usr/local/bin> with the following commands
$ sudo mv prometheus-2.51.1.linux-amd64/prometheus /usr/local/bin
$ sudo mv prometheus-2.51.1.linux-amd64/promtool /usr/local/bin

# create a primetheus directory in the </etc> directory
$ sudo mkdir /etc/prometheus
