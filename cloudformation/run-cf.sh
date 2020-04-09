#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage : $0 package-lambda | create-stack | delete-stack"
    exit
fi

stack_name='dynamo-test'
cloudformation_role='arn:aws:iam::903167650995:role/WorkshopWithCloudFoundry'

case "$1" in
'package-lambda')
mkdir -p build
aws2 cloudformation package --template workshop-template-original.yaml \
--s3-bucket btkach-cloud-formation-playground > build/workshop-template-packaged.yaml
;;
'create-stack')
echo 'creating stack '$stack_name
result=$(aws2 cloudformation create-stack --stack-name $stack_name --template-body file://build/workshop-template-packaged.yaml \
--role-arn $cloudformation_role --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND)
echo 'created stack:'$result
;;
'delete-stack')
echo 'deleting stack '$stack_name
aws2 cloudformation delete-stack --stack-name $stack_name --output text
;;
'list-stacks') aws2 cloudformation list-stacks
;;
'get-endpoint') aws2 cloudformation describe-stacks --stack-name $stack_name --query "Stacks[0].Outputs[?OutputKey=='APIDomainNameWithStage'].OutputValue" --output text
;;
'redeploy')
./run-cf.sh delete-stack
./run-cf.sh package-lambda
./run-cf.sh create-stack
;;
*) echo "Unsupported parameter $1"
;;
esac