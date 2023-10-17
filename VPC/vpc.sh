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

    
# create first-public-subnet in first zone Az1
create_subnet()
{
    #$1 subnet_num , $2 az , $3 pub or private 
    subnet_check=$(aws ec2 describe-subnets --region us-west-2 --filters Name=tag:Name,Values=sub-$3-$1-devops90 | grep -oP '(?<="SubnetId": ")[^"]*')

    if [ "$subnet_check" == "" ]; then
        echo "subnet $1 is creating ...."
        subnet_result=$(aws ec2 create-subnet  --region us-west-2 --vpc-id $vpc_id --availability-zone us-west-2$2 --cidr-block 10.0.$1.0/24 --tag-specifications ResourceType=subnet,Tags="[{Key=Name,Value=sub-$3-$1-devops90}]"  --output json) 
        echo $subnet_result
        subnet_id=$(echo $subnet_result | grep -oP '(?<="SubnetId": ")[^"]*' )
        if [ "$subnet_id" == "" ]; then
        echo "error in creating subnet "
        exit 1
        fi
    else
    echo " sbnet $1 already exist" 
    subnet_id=$subnet_check
    echo $subnet_id   
    fi
}
create_subnet 1 a public
subnet1_id=$subnet_id
create_subnet 2 b public
subnet2_id=$subnet_id
create_subnet 3 a private
subnet3_id=$subnet_id
create_subnet 4 b private 
subnet4_id=$subnet_id
    
   
# create internet Gateway
igw_check=$(aws ec2 describe-internet-gateways --region us-west-2 --filters Name=tag:Name,Values=Devops90-igw | grep -oP '(?<="InternetGatewayId": ")[^"]*')

if [ "$igw_check" == "" ]; then
   igw_result=$(aws ec2 create-internet-gateway  --region us-west-2  --tag-specifications ResourceType=internet-gateway,Tags=[{Key=Name,Value=Devops90-igw}])
   echo $igw_result
   igw_id=$(echo igw_result | grep -oP '(?<="InternetGatewayId": ")[^"]*')
    if [ "$igw_id" == "" ]; then
    echo "Error in creating IGW"
    exit 1
    fi
    echo "IGW create
else
    igw_id=$igw_check
fi    
echo $igw-id
