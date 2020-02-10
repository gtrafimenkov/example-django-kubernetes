# Kubernetes enabled django-todo application

- [Overview](#overview)
	- [Application Docker Image](#application-docker-image)
	- [Helm chart](#helm-chart)
- [Limitations](#limitations)
- [Local development](#local-development)
	- [Local test with docker](#local-test-with-docker)
- [Deploying to k8s](#deploying-to-k8s)
	- [Before you begin](#before-you-begin)
	- [First install of the application](#first-install-of-the-application)
	- [Upgrade of the deployed chart](#upgrade-of-the-deployed-chart)
- [Deploy AWS EKS test cluster](#deploy-aws-eks-test-cluster)
- [Final works](#final-works)

## Overview

This repository contains an example of how [django-todo](https://github.com/shacker/django-todo)
application can be modified for deployment to Kubernetes.

Components:
  - `docker` - Files necessary to build the application docker image
  - `infra` - Infrastructure code for deploying AWS EKS k8s cluster
  - `k8s` - Application helm chart and other files necessary for k8s deployment
  - `project` - Django project forked from https://github.com/shacker/gtd
  - `todo` - django-todo application forked from https://github.com/shacker/django-todo
  - `Makefile` contains various build and deploy commands.  Use `make` to see list of available commands.

### Application Docker Image

A single docker image is built.  It contains:
  - application code
  - static files and nginx configuration

A single image can work in different modes:
  - as an application server (gunicorn)
  - as nginx reverse proxy for serving static files and sending requests to an application server

See [entrypoint.sh](docker/entrypoint.sh) for full list of operation modes.

### Helm chart

The helm chart contains:
  - a deployment
  - a Job object for performing DB migrations during the deploy
  - a service

## Limitations

Since it's not a production deployment of the application, but a demo
task, a number of shortcuts were taken:
  - a public Docker registry is used to store docker images
  - application DB name, user, and password are hardcoded in settings.py and create-app-db-and-user.sql
  - k8s default namespace is used to deploy the application and the DB
  - Django secret is hardcoded in settings.py
  - no resource limitations for containers
  - infrastructure code and application code are in the same git repository
  - terraform state is stored locally

## Local development

1. Install pipenv.
2. Run application in the development mode:

```bash
pipenv install
pipenv run ./project/manage.py migrate
pipenv run ./project/manage.py createsuperuser
DJANGO_DEBUG=1 pipenv run ./project/manage.py runserver
```

### Local test with docker

```bash
make build-docker-image
make localtest
```

## Deploying to k8s

### Before you begin

1. You'll need a functional k8s cluster with persistent volumes support.
   Configure kubectl to access the cluster.

   If you need a k8s cluster, see section "Deploy AWS EKS test cluster"
   below on how to setup an AWS EKS test cluster for this task.

2. Configure docker registry.  You will need either to configure you k8s
   cluster to use some private docker registry, or use a public docker
   registry for this exercise.

   Set and export `EXTERNAL_DOCKER_REPO` environment variable or change
   `EXTERNAL_DOCKER_REPO` default value inside the Makefile.  Log in to your
   docker registry.

### First install of the application

1. Deploy Postgres to k8s and create a separate DB for the application.

```bash
make k8s-deploy-postgres
# wait until cph-test-db-postgresql-0 pod is 1/1 Ready and Running
make k8s-create-db
```

2. Build docker image, helm chart and install it.

```bash
make build-docker-image && make publish-docker-image
make k8s-helm-package && make k8s-helm-install
```

### Upgrade of the deployed chart

```bash
make build-docker-image && make publish-docker-image
make k8s-helm-package && make k8s-helm-upgrade
```

## Deploy AWS EKS test cluster

Here are instructions for deploying a simple EKS cluster.

1. Make sure you have AWS account ready, aws cli configured, Terraform version >= 0.12.20
   installed.

2. Change [terraform.tf](./infra/terraform/terraform.tf),
   [provider.tf](./infra/terraform/provider.tf),
   [variables.tf](./infra/terraform/variables.tf), and [.eks-env](./.eks-env)
   settings if necessary.

3. Deploy infrastructure:

   ```
   cd infra/terraform
   terraform init
   terraform apply
   ```

   It will take approximately 15 minutes to deploy the infrastructure.

4. Fetch kubeconfig.

- go back to the root of the repository
- apply set of environment variables: `. .eks-env`
- fetch kubeconfig: `make k8s-eks-get-config`

5. Make sure the cluster is accessible.

   ```
   kubectl get nodes
   ```

## Final works

Don't forget to remove deployed infrastructure if it was deployed:

```
cd infra/terraform
terraform destroy
```
