#!/bin/bash
#get_vpc_id
get_vpc(){
    #$1 name of vpc
    vpc_id=$(aws ec2 describe-vpcs --region us-west-2 --filters Name=tag:Name,Values=$1 | grep -oP '(?<="VpcId": ")[^"]*')
    if [ "$vpc_id" == "" ]; then
    echo "VPC not found"
    exit 1
    fi
    echo $vpc_id

}
get_vpc "devops-90-vpc"
#get_subnet_id
#get_secuirty_group_id
#create_elb
#create_TG
#create_listener
#create_autoscaling_group
#create_Scaling_poilcy
