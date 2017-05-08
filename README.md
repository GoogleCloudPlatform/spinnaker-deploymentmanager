# Deployment Manager Templates for Spinnaker

This repository contains Deployment Manager template for deploying [Spinnaker](http://www.spinnaker.io/).
By default, this will deploy the following topology:

![](images/spinnaker-arch.png)

Spinnaker will store its state in Google Cloud Storage and Redis. Jenkins
is used to run scripts required during the build process or in order to trigger
a pipeline.

## Deploying

1. Download the repository.
1. Create the deployment:

        export GOOGLE_PROJECT=$(gcloud config get-value project)
        export DEPLOYMENT_NAME="${USER}-test1"
        export JENKINS_PASSWORD=$(openssl rand -base64 15)
        gcloud deployment-manager deployments create --config config.jinja ${DEPLOYMENT_NAME} --properties jenkinsPassword:${JENKINS_PASSWORD}

1. Once instance provisioning is complete get the name of your Spinnaker and Jenkins instances by
   running:

        export SPINNAKER_VM=$(gcloud compute instances list --regexp "${DEPLOYMENT_NAME}-spinnaker.+" --uri)
        export JENKINS_VM=$(gcloud compute instances list --regexp "${DEPLOYMENT_NAME}-jenkins.+" --uri)

1. Creating an SSH tunnel to your Spinnaker instance as follows:

        gcloud compute ssh ${SPINNAKER_VM} -- -L 8081:localhost:8081 -L8080:$(basename $JENKINS_VM):8080

1. After a few minutes, you can access the Spinnaker and Jenkins UIs respectively by visiting the following web address:

        http://localhost:8081
        http://localhost:8080

## Teardown

1. Stop the front50 service then delete the GCS objects and bucket:

       gcloud compute ssh ${SPINNAKER_VM} -- sudo service front50 stop
       gsutil rm -r gs://spinnaker-${GOOGLE_PROJECT}-${DEPLOYMENT_NAME}/front50
       gsutil rb gs://spinnaker-${GOOGLE_PROJECT}-${DEPLOYMENT_NAME}

1. Delete the deployment by running:

       gcloud deployment-manager deployments delete ${DEPLOYMENT_NAME}
