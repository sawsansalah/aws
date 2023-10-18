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
   echo "igw will be created..." 
   igw_id=$(aws ec2 create-internet-gateway  --region us-west-2  --tag-specifications ResourceType=internet-gateway,Tags="[{Key=Name,Value=Devops90-igw}]" | grep -oP '(?<="InternetGatewayId": ")[^"]*')
   if [ "$igw_id" == "" ]; then
    echo "Error in creating IGW"
    exit 1
    fi
    echo "IGW created.."
else
    echo "IGW already exist.."
    igw_id=$igw_check
fi    
echo $igw_id

#### attach vpc 
igw_attatch=$(aws ec2 describe-internet-gateways --region us-west-2 --internet-gateway-ids $igw_id | grep -oP '(?<="VpcId": ")[^"]*')
if [ "$igw_attatch" != "$vpc_id" ]; then
   echo "igw will be attached ..."
   igw_result=$(aws ec2 attach-internet-gateway --region us-west-2 --internet-gateway-id $igw_id --vpc-id $vpc_id)
   if [ "$igw_result" == "" ]; then
      echo "igw attatched"
   else
      echo "igw aleady assoicated"
   fi   
else
   echo "Internet gateway already attached to this vpc"
fi
## create public routetable 
rt_check=$(aws ec2 describe-route-tables --region us-west-2 --filters Name=tag:Name,Values=Devops90-pub-rtb | grep -oP '(?<="RouteTableId": ")[^"]*')
if [ "$rt_check" == " " ]; then
   echo "pub routing table will be created ..."
   rt_table_id=$(aws ec2 create-route-table --region us-west-2 --vpc-id $vpc_id  --tag-specifications ResourceType=route-table,Tags="[{Key=Name,Value=Devops90-pub-rtb}]" | grep -oP '(?<="RouteTableId": ")[^"]*')
   if [ "$rt_table_id" == "" ]; then
      echo "Error in creating public routing table"
      exit 1
   else
      echo "public routing table created "
   fi   
route_result=$(aws ec2 create-route --route-table-id $rt_table_id --destination-cidr-block 0.0.0.0/0 --gateway-id  $igw_id | grep -oP '(?<="Return": ")[^"]*')
echo $route_result
   if [ "$route_result" != "true" ]; then
        echo "public route creation faild"
        exit 1
   fi
    echo "public route created"

else
   echo "pub routing table already exists...."
   pub_rt_id=$rt_check
   echo $pub_rt_id
fi
aws ec2 associate-route-table --route-table-id $pub_rt_id --subnet-id $subnet1_id
aws ec2 associate-route-table --route-table-id $pub_rt_id --subnet-id $subnet2_id

