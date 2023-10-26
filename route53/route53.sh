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
    echo "$hosted_zone_id"

  fi
}


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


create_dns_record() {
   #$1,subdomain
   full_sub_domain="$1.dns_name"
       change=$(cat << EOF
{
  "Changes": 
  [
    {
      "Action": "CREATE",
      "ResourceRecordSet": 
      {
        "Name": "$full_sub_domain",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": 
        [
          {
            "Value": "$2"
          }
        ]
      }
    }
  ]
}
EOF
)
  change=$( echo $change | tr -d '\n' | tr -d ' ')

   record_check=$(aws route53 list-resource-record-sets --hosted-zone-id $hosted_zone_id --query "ResourceRecordSets[?Name == '$full_sub_domain' ]" |  grep -oP '(?<="Name": ")[^"]*')
   if [ "$record_check" == "" ]; then
      echo "DNS record will be created "
      record_id=$(aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch $change --query HostedZone | grep -oP '(?<="Id": ")[^"]*')
        
        if [ "$record_id" == "" ]; then
            echo "Error in create DNS Record"
            exit 1
        fi
        echo "DNS Record created."

    else
        echo "DNS Record already exist."
    fi
  



}

create_hosted_zone
get_instance_ip "devops90"
create_dns_record srv2
