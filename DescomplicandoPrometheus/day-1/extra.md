## Extra commands
### run Prometheus without install
sudo ./prometheus

### check Prometheus process
ps -ef | grep prometheus

### end running Prometheus service
#### number must be the same as the one that appears in the Prometheus process execution command
sudo kill -9 38104

### exemple query
process_cpu_seconds_total{job="prometheus"}[2m]

### remove all of the Prometheus
sudo rm -rf /var/lib/prometheus

### delete user
sudo deluser prometheus