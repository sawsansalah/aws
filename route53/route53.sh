#!/bin/bash

region="us-east-1"
dns_name="devops90.link"

create_hosted_zone() {
  check_zone=$(aws route53 list-hosted-zones-by-name --dns-name $dns_name | grep -oP '(?<="Id": ")[^"]*' | uniq)
  if [ "$check_zone" == "" ]; then
    echo "Hosted Zone will be created ....."
    date=$(date -u +"%Y-%m-%d-%H-%M-%S")
    hosted_zone_id=$(aws route53 create-hosted-zone --name $dns_name --caller-reference $date | grep -oP '(?<="Id": ")[^"]*' | uniq)
    if [ "$hosted_zone_id" == "" ]; then
      echo "Error in creating hosted Zone..."
      exit 1
    fi
    echo "Hosted zone created $hosted_zone_id"
  else
    echo "Hosted Zone already exists."
    hosted_zone_id=$check_zone
  fi
}

create_hosted_zone

get_instance_ip() {
  #$1 ec2 name 
  check_instance=$(aws ec2 describe-instances --region=$region --filters=Name=tag:Name,Values=$1 | grep -oP '(?<="PublicIpAddress": ")[^"]*')
  if [ "$check_instance" == "" ]; then
    echo "Instance EC2 $1 does not exist."
    exit 1
  else
    echo "Instance $1 found, public IP is $check_instance"
  fi
}

get_instance_ip "devops90"