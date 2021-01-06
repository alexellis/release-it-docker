Version := $(shell git describe --tags --dirty)
GitCommit := $(shell git rev-parse HEAD)
PublicKey := "test this string"
export DOCKER_CLI_EXPERIMENTAL=enabled

.PHONY: docker
docker:
	docker build --build-arg PUBLIC_KEY=$(PublicKey) --build-arg VERSION=$(Version) --build-arg GIT_COMMIT=$(GitCommit) -t alexellis/release-it:$(Version)-amd64 .
