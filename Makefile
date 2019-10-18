LINTER_VERSION=1.21.0

all: clean build test vet lint

ci: all report

setup:
	go get -u golang.org/x/lint/golint
	go get -u golang.org/x/tools/cmd/cover

ifeq (, $(shell which go))
     $(error "Go isn't installed!")
endif

ifeq (, $(shell which golangci-lint))
     wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v$(LINTER_VERSION)
endif

build:
	go build

clean:
	go clean
	rm -f *.out *.prof *.test
	go mod tidy

vet:
	go vet ./...

lint:
	golangci-lint run
	golint ./...

test:
	go test -v -covermode=count ./...

doc:
	godoc --http=:6060

profile:
	go test --cpuprofile cpu.prof --memprofile mem.prof -bench ./...

report:
	go test -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out
