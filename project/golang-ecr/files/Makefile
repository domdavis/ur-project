ifeq (, $(BINARY))
BINARY = {PACKAGE}
endif

IMAGE = {USERNAME}/$(BINARY)
PACKAGE = bitbucket.org/{USERNAME}/{PACKAGE}/config
BUILD_TIME = $(shell date +"%Y/%m/%d-%H:%M:%S")
HASH = $(shell git rev-parse HEAD)

ifdef BITBUCKET_TAG
TAG = $(BITBUCKET_TAG)
else ifdef BITBUCKET_BRANCH
TAG = $(BITBUCKET_BRANCH)
else
TAG = $(shell git rev-parse --abbrev-ref HEAD)
endif

ifeq (, $(TAG))
TAG = dev
endif

LDFLAGS = -X $(PACKAGE).BuildTimestamp=$(BUILD_TIME) \
	-X $(PACKAGE).BuildHash=$(HASH) \
	-X $(PACKAGE).BuildVersion=$(TAG)

all: clean build lint test

build:
	go vet ./...
	CGO_ENABLED=0 go build -ldflags "$(LDFLAGS)" -o "$(BINARY)"

linux:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "$(LDFLAGS)" -o "$(BINARY)"

clean:
	go clean

lint:
	golangci-lint run

test:
	go test -covermode=count -count=1 ./...

docker: linux
	docker build -t $(IMAGE) .

ci: all

release: all
	go mod tidy

run:
	go run main.go -c config.json

.PHONY: test
.DEFAULT_GOAL := all
