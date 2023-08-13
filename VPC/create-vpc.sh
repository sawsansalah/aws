#!/bin/bash
vpc_result=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region eu-north-1  --tag-specification ResourceType=vpc,Tags="[{Key=Name,Value=Devops90-vpc}]" --output json)

echo $vpc_result

vpc_id =$(vpc_result  | grep -oP '(?<="VpcId": ")[^"]*')
echo $vpc_id

#aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.1.0/24 --tag-specifications ResourceType=subnet,Tags=[{Key=Name,Value=first-public-subnet}] --availability-zone eu-north-1a --availability-zone-id eun1-az1




