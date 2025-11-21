GOPATH := $(shell go env GOPATH)

check:
	terraform fmt -check -recursive .

format:
	terraform fmt -recursive .

add-license-headers:
	go install github.com/google/addlicense@v1.1.1
	$(GOPATH)/bin/addlicense -v -c 'Bitshift' -y 2025 -l mpl -s=only ./**/*.tf

check-license-headers:
	go install github.com/google/addlicense@v1.1.1
	$(GOPATH)/bin/addlicense -v -check ./**/*.tf
