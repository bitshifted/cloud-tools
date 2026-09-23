GOPATH := $(shell go env GOPATH)


init:
	go install github.com/google/addlicense@v1.1.1
	go install github.com/terraform-docs/terraform-docs@v0.20.0

codeartifact-repo-format: init
	cd ./codeartifact-repo && ../scripts/format.sh 

codeartifact-repo-verify: init
	cd ./codeartifact-repo  && ../scripts/verify.sh 

easy-ecr-format: init
	cd ./easy-ecr && ../scripts/format.sh 

easy-ecr-verify: init
	cd ./easy-ecr  && ../scripts/verify.sh 

ddb-express-format: init
	cd ./ddb-express && ../scripts/format.sh 

ddb-express-verify: init
	cd ./ddb-express  && ../scripts/verify.sh 

nosrv-format: init
	cd ./nosrv && ../scripts/format.sh 

nosrv-verify: init
	cd ./nosrv  && ../scripts/verify.sh
