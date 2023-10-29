#!/bin/bash
#get_vpc_id
get_vpc(){
    #$1 name of vpc
    vpc_id=$(aws ec2 describe-vpcs --region us-east-1 --filters Name=tag:Name,Values=$1 | grep -oP '(?<="VpcId": ")[^"]*')
    if [ "$vpc_id" == "" ]; then
    echo "VPC not found"
    exit 1
    fi
    echo $vpc_id

}
get_vpc "devops-90-vpc"

#get_subnet_id
get_subnet_id(){
    #$1 subnet name
    subnet_id=$(aws ec2 describe-subnets --region us-east-1 --filters Name=tag:Name,Values=$1 | grep -oP '(?<="SubnetId": ")[^"]*')
    if [ "$subnet_id" == "" ]; then
    echo "subnet not found"
    exit 1
    fi
    echo $subnet_id
}
get_subnet_id "public-subnet-01"
public_subnet_01=$subnet_id
echo $public_subnet_01
get_subnet_id "public-subnet-02"
public_subnet_01=$subnet_id
echo $public_subnet_02
 subnets_ids="${public_subnet_01},${public_subnet_02}"
 subnets_ids_space="${public_subnet_01} ${public_subnet_02}"
 echo $subnets_ids
 echo $subnets_ids_space



#get_secuirty_group_id
#create_elb
#create_TG
#create_listener
#create_autoscaling_group
#create_Scaling_poilcy
