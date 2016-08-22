# Deployment Manager Templates for Spinnaker

This repository contains Deployment Manager template for deploying [Spinnaker](http://www.spinnaker.io/).
By default, this will deploy the following topology:

![](images/spinnaker-arch.png)

Spinnaker will store its state in Google Cloud Storage and Redis. Jenkins
is used to run scripts required during the build process or in order to trigger
a pipeline.

## Deploying

1. Download the repository.
1. Ensure the configuration of the cluster is to your liking in `config.yaml`
1. Set the Jenkins Password in `config.yaml`
1. Create the deployment:

       gcloud deployment-manager deployments create --config config.yaml prod
1. Once instance provisioning is complete get the name of your Spinnaker instance by
   running:

       gcloud compute instances list | grep spinnaker
1. Access the Spinnaker UI by creating an SSH tunnel to your Spinnaker instance as follows:

       gcloud compute ssh prod-spinnaker-ogo8 --zone us-west1-a -- -L 9000:localhost:9000 -L8084:localhost:8084

## Teardown

1. Delete the deployment by running:

       gcloud deployment-manager deployments delete prod
