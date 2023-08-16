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
create_subnet()
{  # $1 subnet number , $2 az , $3 public or private 
    subnet_check=$(aws ec2 describe-subnets --region eu-north-1  --filters  Name=tag:Name,Values=sub-$3-$1-devops90 | grep -oP '(?<="SubnetId": ")[^"]*')
    if [ "$subnet_check" == "" ];then
        echo "subnet $1 will be created... "
        subnet_result=$(aws ec2 create-subnet \
            --vpc-id $vpc_id \
            --cidr-block 10.0.$1.0/24 \
            --tag-specifications ResourceType=subnet,Tags="[{Key=Name,Value=sub-$3-$1-devops90}]" \
            --availability-zone eu-north-1$2	 \
            --output json)
        echo $subnet_result    
        subnet_id=$(echo $subnet_result |  grep -oP '(?<="SubnetId": ")[^"]*')   
        echo $subnet_id 
        # Allow Error handling per subnet-id
        if [ "$subnet_id" == "" ]; then
        echo "Error in creating subnet $1"
        exit 1 
        fi   
    else
        echo "subnet $1 already exist"
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
#------------------------------
# create internet Gateway
Gateway_check=$(aws ec2 describe-internet-gateways --region eu-north-1  --filters  Name=tag:Name,Values=Devops90-igw | grep -oP '(?<="InternetGatewayId": ")[^"]*')
if [ "$Gateway_check" == "" ]; then
   echo "The internet-gateway will be created ......"
   Gateway_result=$(aws ec2 create-internet-gateway \
            --region eu-north-1 \
            --tag-specifications ResourceType=internet-gateway,Tags="[{Key=Name,Value=Devops90-igw}]" \
            --output json) 
   echo $Gateway_result
   GatewayId=$(echo $Gateway_result | grep -oP '(?<="InternetGatewayId": ")[^"]*' )
   echo $GatewayId
   # Allow Error handling per IG 
        if [ "$GatewayId" == "" ]; then
        echo "Error in creating InternetGateway...."
        exit 1 
        fi   
else
  echo "InternetGateway is exsist .........."
  GatewayId=$Gateway_check
fi  
echo $GatewayId
#----------------------------------------
# Attatch the internet Gateway to vpc 

attatch_check=$(aws ec2 describe-internet-gateways \
    --internet-gateway-ids $GatewayId | grep -oP '(?<="VpcId": ")[^"]*')
if [ "$attatch_check" == "" ]; then

    attatch_result=$(aws ec2 attach-internet-gateway --internet-gateway-id $GatewayId  --vpc-id $vpc_id)

    echo "  internet gateway attached ....."
else
  echo "  internet gateway didn't attached ....."
fi       

#-------------------------------
## create public route table 

rtb_check=$(aws ec2 describe-route-tables --filters  Name=tag:Name,Values=pub-Devops90-rtb | grep -oP '(?<="RouteTableId": ")[^"]*' | uniq)

if [ "$rtb_check" == "" ]; then
   echo "the private routing table will be created ........."
   pub_rtb_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications ResourceType=route-table,Tags="[{Key=Name,Value=pub-Devops90-rtb}]" --output json |  grep -oP '(?<="RouteTableId": ")[^"]*' | uniq)  
    # Allow Error handling per IG 
    if [ "$RouteTableId" == "" ]; then
        echo "Error in creating public routing table ...."
        exit 1 
        fi   
    route_result=$(aws ec2 create-route --route-table-id $pub_rtb_id --destination-cidr-block 0.0.0.0/0 --gateway-id $GatewayId | grep -oP '(?<="RouteTableId": ")[^"]*'| uniq)  
    echo $route_result
    if [ "$route_result" != "true" ]; then
        echo "Error in creating  routing table ...."
        exit 1 
        fi   
    
else
  pub_rtb_id=$rtb_check
  echo $pub_rtb_id
fi
# Assoicate public route table to public subnets 
aws ec2 associate-route-table --route-table-id $pub_rtb_id --subnet-id $subnet1_id
aws ec2 associate-route-table --route-table-id $pub_rtb_id --subnet-id $subnet2_id

#-------------------------------
## create public route table 
rtb_check=$(aws ec2 describe-route-tables --filters  Name=tag:Name,Values=private-Devops90-rtb | grep -oP '(?<="RouteTableId": ")[^"]*'| uniq)

if [ "$rtb_check" == "" ]; then
   echo "the private routing table will be created ........."
   private_rtb_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications ResourceType=route-table,Tags="[{Key=Name,Value=private-Devops90-rtb}]" --output json |  grep -oP '(?<="RouteTableId": ")[^"]*'| uniq)  
    # Allow Error handling per IG 
    if [ "$private_rtb_id" == "" ]; then
        echo "Error in creating private routing table ...."
        exit 1 
        fi   
 
else
  private_rtb_id=$rtb_check
  echo $private_rtb_id
fi
# Assoicate public route table to public subnets 
aws ec2 associate-route-table --route-table-id $private_rtb_id --subnet-id $subnet3_id
aws ec2 associate-route-table --route-table-id $private_rtb_id --subnet-id $subnet4_id
