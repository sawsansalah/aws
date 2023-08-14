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
    if [ "$vpc_id" == "" ]; then
    echo "Error in creating vpc"
    exit 1 
    fi    


    echo "vpc created "
else
    echo "VPC already exsit"
    vpc_id=$vpc_check
    echo $vpc_id
fi  
#---------------------------------------------
# create first-public-subnet in first zone Az1
subnet_check=$(aws ec2 describe-subnets --region eu-north-1  --filters  Name=tag:Name,Values=Devops-public-zone-1 | grep -oP '(?<="SubnetId": ")[^"]*')
if [ "$subnet_check" == "" ];then
    echo "subnet 1 will be created... "
    subnet_result=$(aws ec2 create-subnet \
        --vpc-id $vpc_id \
        --cidr-block 10.0.1.0/24 \
        --tag-specificatio1s ResourceType=subnet,Tags="[{Key=Name,Value=Devops-public-zone-1}]" \
        --availability-zone eu-north-1a	 \
        --availability-zone-id eun1-az1   \
        --output json)
    subnet_id=$(echo $subnet_result |  grep -oP '(?<="SubnetId": ")[^"]*')   
    echo $subnet_id 
     # Allow Error handling per vpc_id
    if [ "$subnet_id" == "" ]; then
    echo "Error in creating subnet1"
    exit 1 
    fi   
else
    subnet_id=$subnet_check
    echo $subnet_id
fi