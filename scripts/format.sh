#! /bin/bash

GOPATH=$(go env GOPATH)

echo "Formatting files..."

echo "Adding license headers..."
$GOPATH/bin/addlicense -c 'Bitshift' -y 2025 -l mpl -s=only ./*.tf || exit 1
cd tests && $GOPATH/bin/addlicense -check -c 'Bitshift' -y 2025 -l mpl -s=only ./*.tftest.hcl || exit 1
cd ..

echo "License headers added successfully"

echo "Running Terraform format..."
terraform fmt  || exit 1
echo "Terraform formatting successfull"
