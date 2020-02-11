# aws-workshop
Code examples for workshop 


## AWS clean up 

Remove checklist:
- ec2 instances
- dynamoDb tables
- api gateway routes


AWS API Gateway allows only one removal per minute, which makes cleaning up after workshop a bit difficult. 


Use aws-clean-up/index.js to remove all apis and dynamodb tables created in all regions. 