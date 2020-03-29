#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage : $0 package-lambda | create-stack | delete-stack"
    exit
fi

case "$1" in
'package-lambda')
mkdir -p build
aws2 cloudformation package --template workshop-template-original.yaml \
--s3-bucket btkach-cloud-formation-playground > build/workshop-template-packaged.yaml
;;
'create-stack') aws2 cloudformation create-stack --stack-name dynamo-test --template-body file://build/workshop-template-packaged.yaml \
--role-arn arn:aws:iam::903167650995:role/WorkshopWithCloudFoundry --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND
;;
'delete-stack') aws2 cloudformation delete-stack --stack-name dynamo-test
;;
'list-stacks') aws2 cloudformation list-stacks
;;
*) echo "Unsupported parameter $1"
;;
esac