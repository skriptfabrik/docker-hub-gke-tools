DOCKER_BUILD_OPTIONS?=
DOCKER_IMAGE_NAME?=skriptfabrik/gke-tools
DOCKER_IMAGE_TAG?=latest
DOCKER_PLATFORMS?=linux/amd64

.PHONY: default
default: lint build

.PHONY: lint
lint:
	@echo 'Linting Dockerfile'
	@docker run --rm -i hadolint/hadolint < Dockerfile

.PHONY: build
build:
	@echo "Building Docker image"
	@docker buildx build \
		--cache-from $(DOCKER_IMAGE_NAME):latest \
		--output type=image \
		--platform $(DOCKER_PLATFORMS) \
		--pull \
		--tag $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) \
		$(DOCKER_BUILD_OPTIONS) \
		.

.PHONY: clean
clean:
	@echo "Cleaning up Docker images"
	-@docker rmi --force $(shell docker images $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG) -q)
