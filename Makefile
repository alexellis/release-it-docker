Version := $(shell git describe --tags --dirty)
GitCommit := $(shell git rev-parse HEAD)

export DOCKER_CLI_EXPERIMENTAL=enabled
export GOPRIVATE="github.com/alexellis/jwt-license"

.PHONY: docker
docker:
	docker build --build-arg PUBLIC_KEY=$(PublicKey) --build-arg VERSION=$(Version) --build-arg GIT_COMMIT=$(GitCommit) -t openfaas/kafka-connector-pro:$(Version)-amd64 .
