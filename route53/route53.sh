#!/bin/bash
region="us-east-1"
dns_name="devops90.link"

create_hosted_zone()
{
  check_zone=$(aws route53 list-hosted-zones-by-name --dns-name $dns_name |  grep -oP '(?<="Id": ")[^"]*' | uniq)
  if [ "$check_zone" == "" ]; then
     echo " Hosted Zone will be created ....."
     date=$(date -u +"%Y-%m-%d-%H-%M-%S")
     hosted_zone_id=$(aws route53 create-hosted-zone --name $dns_name --caller-reference $date | grep -oP '(?<="Id": ")[^"]*' | uniq )
     if [ "$hosted_zone_id" == "" ];then
        echo "Error in created hosted Zone..."
        exit 1
     fi
     echo "hosted zone created $hosted_zone_id "    
  
  else
      echo "Hosted Zone already exist."
      hosted_zone_id=$check_zone
  
}
create_hosted_zone
get_instance_ip()
{
    #$1 ec2 name 
    check_instance=$(aws ec2 describe-instances --region=$region --filters=Name=tag:Name,Values=$1 |grep -oP '(?<="PublicIpAddress": ")[^"]*'  ) 
    if ["$check_instance" == ""]; then
       echo "instance EC2 $1 not exsist"
       exit 1
    else
       echo "instance $1 found , public ip is  $check_instance "  

    fi
}
get_instance_ip "devops90"
