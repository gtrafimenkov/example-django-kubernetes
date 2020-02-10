VERSION := $(shell git describe --dirty --broken)

# If environment variable EXTERNAL_DOCKER_REPO is not defined, using default value
ifeq ($(strip $(EXTERNAL_DOCKER_REPO)),)
EXTERNAL_DOCKER_REPO := docker.io/gtrafimenkov/cph-test2
endif

# Print usage instructions by default
default:
	@echo "Usage:"
	@grep @doc Makefile | grep -v grep | sed 's/# @doc/-/g' | sed s/://g | sed -e 's/^/  /'

build-docker-image:		# @doc Builds the docker image
	docker build \
		-t cph-test:${VERSION} \
		-t cph-test:latest \
		-t ${EXTERNAL_DOCKER_REPO}:${VERSION} \
		-f docker/Dockerfile .

publish-docker-image:		# @doc Publish docker image to the public repository
	docker push ${EXTERNAL_DOCKER_REPO}:${VERSION}

localtest:			# @doc Run application locally in docker
	@echo "=========================================================="
	@echo "Use http://localhost:8080 to access the application."
	@echo "Use admin/admin to log in as superuser."
	@echo "=========================================================="
	docker run --rm -it -p 8080:8080 -p 8081:8081 cph-test:latest migrate create-test-superuser debug

k8s-eks-get-config:		# @doc Fetch kubeconfig for the EKS cluster
	aws --region $$AWS_REGION eks update-kubeconfig --name $$EKS_CLUSTER

k8s-helm-package:		# @doc Build helm package
	mkdir -p build/helm-charts
	helm package \
		--version ${VERSION} \
		--app-version ${VERSION} \
		-d build/helm-charts \
		k8s/helm-charts/cph-test/

k8s-deploy-postgres:		# @doc Deploy Postgres server
	k8s/provision/08-deploy-postgres.sh

k8s-create-db:			# @doc Create a separate DB for the application
	k8s/provision/10-create-app-db-and-user.sh

k8s-helm-install:		# @doc Install newly built helm package
	helm install \
		--set image.repository=${EXTERNAL_DOCKER_REPO} \
		cph-test build/helm-charts/cph-test-${VERSION}.tgz

k8s-helm-render:		# @doc Display rendered helm chart
	helm install \
		--dry-run \
		--set image.repository=${EXTERNAL_DOCKER_REPO} \
		cph-test-dry-run build/helm-charts/cph-test-${VERSION}.tgz | less

k8s-helm-upgrade:		# @doc Upgrade installed application
	helm upgrade \
		--set image.repository=${EXTERNAL_DOCKER_REPO} \
		cph-test build/helm-charts/cph-test-${VERSION}.tgz

k8s-helm-uninstall:		# @doc Uninstall the application
	helm uninstall cph-test

k8s-app-portforward:		# @doc Forward application port locally
	@echo "=========================================================="
	@echo "Use http://localhost:8080 to access the application."
	@echo "Use 'make k8s-app-create-superuser' to create a superuser."
	@echo "=========================================================="
	kubectl port-forward \
		$$(kubectl get pods --field-selector=status.phase=Running -l app.kubernetes.io/instance=cph-test -o jsonpath='{.items[0].metadata.name}') \
		8080:8080

k8s-app-create-superuser:	# @doc Create the superuser for deployed application
	kubectl exec \
		$$(kubectl get pods --field-selector=status.phase=Running -l app.kubernetes.io/instance=cph-test -o jsonpath='{.items[0].metadata.name}') \
		-c app -it -- pipenv run /opt/cph-test/project/manage.py createsuperuser

k8s-app-get-loadbalancer-url:	# @doc Returns loadbalancer url of the application
	@echo "http://$$(kubectl get svc cph-test -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

update-toc:			# @doc Update readme.md table of content
	markdown-toc --min 2 readme.md
