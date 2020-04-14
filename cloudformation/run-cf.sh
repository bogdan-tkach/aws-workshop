#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage : $0 package-lambda | create-stack | delete-stack"
  exit
fi

s3_bucket='btkach-cloud-formation-playground'
stack_name='dynamo-test'
cloudformation_role='arn:aws:iam::903167650995:role/WorkshopWithCloudFoundry'

function get_stack_id() {
  local stack_id="$(aws2 cloudformation describe-stacks --stack-name $stack_name --query "Stacks[0].StackId" --output text)"
  echo "$stack_id"
}

function package_template() {
  echo 'packaging cloudformation template'
  mkdir -p build
  aws2 cloudformation package --template workshop-template-original.yaml \
  --s3-bucket $s3_bucket >build/workshop-template-packaged.yaml
  echo 'template updated'
}

function create_stack() {
  echo 'creating stack '$stack_name
  aws2 cloudformation create-stack --stack-name $stack_name --template-body file://build/workshop-template-packaged.yaml \
  --role-arn $cloudformation_role --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND
  echo 'waiting for creation to complete'
  aws2 cloudformation wait stack-create-complete --stack-name $stack_name
  echo 'created stack:' $(get_stack_id)
}

function delete_stack() {
  stack_id=$(get_stack_id)
  if [ -z "$stack_id" ]; then
    echo "stack id is empty. Stack "$stack_name" doesn't exist?"
  else
    echo 'deleting stack '$stack_name' with id '"$stack_id"
    aws2 cloudformation delete-stack --stack-name $stack_name
    echo 'waiting for deletion to complete'
    aws2 cloudformation wait stack-delete-complete --stack-name "$stack_id" --output text --query "Stacks"
    echo 'stack '$stack_name' deleted'
  fi
}

function get_endpoint() {
    aws2 cloudformation describe-stacks --stack-name $stack_name --query "Stacks[0].Outputs[?OutputKey=='APIDomainNameWithStage'].OutputValue" --output text
}

function test() {
  echo 'running test against stack endpoint: '$(get_endpoint)
  cd ../lambda-node-js
  env ENDPOINT=$(get_endpoint) npm test
}

case "$1" in
'package-template')
  package_template
  ;;
'create-stack')
  create_stack
  ;;
'delete-stack')
  delete_stack
  ;;
'list-stacks')
  aws2 cloudformation list-stacks
  ;;
'get-endpoint')
get_endpoint
  ;;
'get-stack-id')
  get_stack_id
  ;;
'redeploy')
  delete_stack
  package_template
  create_stack
  test
  ;;
*)
  echo "Unsupported parameter $1"
  ;;
esac
