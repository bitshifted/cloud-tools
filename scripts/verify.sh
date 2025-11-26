#! /bin/bash
GOPATH=$(go env GOPATH)

echo "Running verification steps..."

echo "Checking license headers..."
$GOPATH/bin/addlicense -check -c 'Bitshift' -y 2025 -l mpl -s=only ./*.tf || exit 1
cd tests && $GOPATH/bin/addlicense -check -c 'Bitshift ' -y 2025 -l mpl -s=only ./*.tftest.hcl || exit 1
cd ..

echo "License headers verification successfull"

echo "Running Terraform validation..."
terraform init && terraform validate || exit 1
echo "Terraform validation successfull"

echo "Running Terraform format check..."
terraform fmt -check || exit 1
echo "Terraform fmt verification successfull"

echo "Running Terraform tests"
terraform test || exit 1
echo "Terraform tests successfull"

echo "Running tflint..."
tflint || exit 1
echo "Tflint check successfull"

echo "Running Checkov scan..."
checkov -d . || exit 1
echo "Checkov scan successfull"