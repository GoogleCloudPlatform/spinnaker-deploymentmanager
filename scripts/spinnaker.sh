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

metadata_value() {
  curl --retry 5 -sfH "Metadata-Flavor: Google" \
       "http://metadata/computeMetadata/v1/$1"
}

PROJECT_ID=`metadata_value "project/project-id"`
DEPLOYMENT=`metadata_value "instance/attributes/deployment"`
REGION=`metadata_value "instance/attributes/region"`
ZONE=`metadata_value "instance/attributes/zone"`
JENKINS_IP=`metadata_value "instance/attributes/jenkinsIP"`
JENKINS_PASSWORD=`metadata_value "instance/attributes/jenkinsPassword"`
REDIS_IP=`metadata_value "instance/attributes/redisIP"`

curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
curl -sSO https://repo.stackdriver.com/stack-install.sh
bash stack-install.sh --write-gcm

echo "deb https://dl.bintray.com/spinnaker/debians trusty spinnaker" > /etc/apt/sources.list.d/spinnaker.list
curl -s -f "https://bintray.com/user/downloadSubjectPublicKey?username=spinnaker" | apt-key add -
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update
apt-get install -y openjdk-8-jdk spinnaker-clouddriver \
                   spinnaker-deck spinnaker-echo spinnaker-front50 \
                   spinnaker-gate spinnaker-igor spinnaker-orca \
                   spinnaker-rosco spinnaker unzip

# Configure Web Server for Gate
echo "Listen 127.0.0.1:9000" >> /etc/apache2/ports.conf
service apache2 restart

# Install Packer
mkdir -p /tmp/packer
pushd /tmp/packer
  curl -s -L -O https://releases.hashicorp.com/packer/0.8.6/packer_0.8.6_linux_amd64.zip
  unzip -u -o -q packer_0.8.6_linux_amd64.zip -d /usr/bin
popd
rm -rf /tmp/packer
cat > /etc/default/spinnaker <<EOF
GATE_OPTS="-Dspring.profiles.active=local,googleOAuth"
SPINNAKER_GOOGLE_ENABLED=true
SPINNAKER_GOOGLE_PROJECT_ID=$PROJECT_ID
SPINNAKER_DEFAULT_STORAGE_BUCKET=spinnaker-$PROJECT_ID-$DEPLOYMENT
SPINNAKER_GOOGLE_DEFAULT_REGION=$REGION
SPINNAKER_GOOGLE_DEFAULT_ZONE=$ZONE

SPINNAKER_JENKINS_ENABLED=true
SPINNAKER_JENKINS_BASEURL=http://$JENKINS_IP/
SPINNAKER_JENKINS_USER=jenkins
SPINNAKER_JENKINS_PASSWORD=$JENKINS_PASSWORD

SPINNAKER_REDIS_HOST=$REDIS_IP
EOF

cat >> /opt/spinnaker/config/orca.yml <<EOF
script:
  master: Jenkins
  job: runSpinnakerScript
EOF

wget https://gist.githubusercontent.com/viglesiasce/fa9806d22cb7d9d92761b27693904a11/raw/spinnaker-local.yml -O /opt/spinnaker/config/spinnaker-local.yml

/opt/spinnaker/bin/reconfigure_spinnaker.sh
/opt/spinnaker/install/change_cassandra.sh --echo=inMemory --front50=gcs --change_defaults=true --change_local=false
start spinnaker
service clouddriver restart
service rosco restart
service orca restart
service igor restart
