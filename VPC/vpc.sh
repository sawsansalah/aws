#!/bin/bash
#check vpc already exsist or not 
vpc_check=$(aws ec2 describe-vpcs --region us-west-2 --filters Name=tag:Name,Values=Devops90-VPC | grep -oP '(?<="VpcId": ")[^"]*')

# create vpc 10.0.0.0/16
if [ "$vpc_check" == "" ]; then
    vpc_result=$(aws ec2 create-vpc  --cidr-block 10.0.0.0/16 --tag-specification ResourceType=vpc,Tags="[{Key=Name,Value=Devops90-VPC}]" --region us-west-2 --output json)
    echo $vpc_result
    vpc_id=$(echo $vpc_result | grep -oP '(?<="VpcId": ")[^"]*')
    echo $vpc_id
    ## Error handling if vpc_id not found means something error per vpc
    if [ "$vpc_id" == "" ]; then
    echo "Error in creating vpc"
    exit 1
    fi
    echo "VPC created"
else
  echo "vpc already exist"
  vpc_id=$vpc_check
  echo $vpc_id
fi      

    
