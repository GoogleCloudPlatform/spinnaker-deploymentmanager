#!/bin/bash -xe
apt-get update
apt-get install -y redis-server
sed -i 's#^bind.*#bind 0.0.0.0#g' /etc/redis/redis.conf
service redis-server restart
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
curl -sSO https://repo.stackdriver.com/stack-install.sh
bash stack-install.sh --write-gcm
