#!/bin/bash
# create vpc 10.0.0.0/16
vpc_result=$(aws ec2 create-vpc  --cidr-block 10.0.0.0/16 --tag-specification ResourceType=vpc,Tags="[{Key=Name,Value=Devops90-VPC}]" --region us-west-2 --output json)
echo $vpc_result
vpc_id=$(echo $vpc_result | grep -oP '(?<="VpcId": ")[^"]*')
echo $vpc_id
## Error handling if vpc_id not found means something error per vpc
if[ "$vpc_id" = "" ]; then
  echo "Error in creating vpc"
  exit 1
fi
echo "VPC created"

    
