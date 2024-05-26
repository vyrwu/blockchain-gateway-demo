app_name?=blockchain-gateway
arch?=amd64
os?=linux
registry_url?=396431934545.dkr.ecr.eu-west-1.amazonaws.com
image_name?=$(registry_url)/$(app_name):latest

run:
	@go run ./...

test:
	@go test

build:
	@GOOS=$(os) GOARCH=$(arch) CGO_ENABLED=0 go build -ldflags="-w -s" -o ./bin/main main.go

image: build
	@docker buildx build --platform $(os)/$(arch) -t $(image_name) --build-arg BINARY_PATH=./bin/main .

publish: image
	@aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(registry_url)
	@docker push $(image_name)

.PHONY: run test build image publish

