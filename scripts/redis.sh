#!/bin/bash -xe
# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install monitoring and logging agents
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
curl -sSO https://repo.stackdriver.com/stack-install.sh
bash stack-install.sh --write-gcm

apt-get update
apt-get install -y redis-server
sed -i 's#^bind.*#bind 0.0.0.0#g' /etc/redis/redis.conf
service redis-server restart
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
curl -sSO https://repo.stackdriver.com/stack-install.sh
bash stack-install.sh --write-gcm
