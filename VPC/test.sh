#!/bin/bash
#check vpc if found or not 
vpc_check=$(aws ec2 describe-vpcs --region eu-north-1 --filters  Name=tag:Name,Values=Devops90-vpc | grep -oP '(?<="VpcId": ")[^"]*')
# create vpc 10.0.0.0/16
if [ "$vpc_check" == "" ]; then
    vpc_result=$(aws ec2 create-vpc \
        --cidr-block 10.0.0.0/16 \
        --tag-specification ResourceType=vpc,Tags="[{Key=Name,Value=Devops90-vpc}]" \
        --region eu-north-1 \
        --output json)
    echo $vpc_result

    vpc_id=$(echo $vpc_result |  grep -oP '(?<="VpcId": ")[^"]*')
    echo $vpc_id

    # Allow Error handling per vpc_id
    if [ "$vpc_id" == ""]; then
    echo "Error in creating vpc"
    exit 1 
    fi    

    echo "vpc created "
else
    echo "VPC already exsit"
fi  