app_name?=polygon-demo
arch?=amd64
os?=linux
image_name?=$(app_name):latest

run:
	@go run ./...

test:
	@go test

build:
	@GOOS=$(os) GOARCH=$(arch) CGO_ENABLED=0 go build -ldflags="-w -s" -o ./bin/main main.go

image: build
	@docker buildx build --platform $(os)/$(arch) -t $(image_name) --build-arg BINARY_PATH=./bin/main .

.PHONY: run test build image

