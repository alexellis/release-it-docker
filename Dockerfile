FROM teamserverless/license-check:0.3.9 as license-check

FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.15 as build

ARG PUBLIC_KEY
ARG GIT_COMMIT
ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor

RUN echo "Checking public key" && test -n "$PUBLIC_KEY"

COPY --from=license-check /license-check /usr/bin/

WORKDIR /go/src/github.com/alexellis/release-it-docker/
COPY . .

RUN license-check -path /go/src/github.com/alexellis/release-it-docker/ --verbose=false "Alex Ellis"
RUN gofmt -l -d $(find . -type f -name '*.go' -not -path "./vendor/*")
RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} go test -v ./...

RUN echo ${GIT_COMMIT} ${VERSION}
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=${CGO_ENABLED} go build \
        -mod=vendor \
        --ldflags "-s -w -X 'github.com/alexellis/release-it-docker/version.GitCommit=${GIT_COMMIT}' -X 'main.PublicKey=${PUBLIC_KEY}' -X 'github.com/alexellis/release-it-docker/version.Version=${VERSION}'" \
        -a -installsuffix cgo -o release-it

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.12 as ship

RUN apk --no-cache add \
    ca-certificates

RUN addgroup -S app \
    && adduser -S -g app app

WORKDIR /home/app

ENV http_proxy      ""
ENV https_proxy     ""

COPY --from=build /go/src/github.com/alexellis/release-it-docker/release-it    /usr/bin/
RUN chown -R app:app ./

USER app

CMD ["/usr/bin/release-it"]
