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
public_subnet_02=$subnet_id
echo $public_subnet_02

subnets_ids="${public_subnet_01},${public_subnet_02}"
echo $subnets_ids

subnets_ids_space="${public_subnet_01} ${public_subnet_02}"
echo $subnets_ids_space



#get_secuirty_group_id
get_secuirty_group_id(){
    #$1 name of security group
  secuirty_group_id=$(aws ec2 describe-security-groups  --region us-east-1 --filters Name=tag:Name,Values=$1 | grep -oP '(?<="GroupId": ")[^"]*' | uniq)
   if [ "$secuirty_group_id" == "" ]; then
    echo "secuirty group not found"
    exit 1
    fi
    echo $secuirty_group_id 
}
get_secuirty_group_id "Devops90-SG"
#create_elb
create_elb(){

    elb_check=$(aws elbv2 describe-load-balancers --region us-east-1 --query "LoadBalancers[?LoadBalancerName == 'devops90-nlp']" | grep -oP '(?<="LoadBalancerArn": ")[^"]*')

    if [ "$elb_check" == "" ]; then
        echo "LB will be created "
        LB_ARN=$(aws elbv2 create-load-balancer --name devops90-nlp --region us-east-1 --type network --subnets $subnets_ids_space --security-groups $secuirty_group_id | grep -oP '(?<="LoadBalancerArn": ")[^"]*' )
        if [ "$LB_ARN" == "" ]; then
        echo "error in creating LB"
        exit 1
        fi
    else
    LB_ARN=$elb_check    
    fi
    echo $LB_ARN
}
create_elb 

#create_TG
create_TG(){
    
    tg_check=$(aws elbv2 describe-target-groups --region us-east-1  --query "TargetGroups[?TargetGroupName == 'devops90-Tg']"| grep -oP '(?<="TargetGroupArn": ")[^"]*') 
    if [ "$tg_check" == "" ]; then
       echo "TG will be created"
       TG_ARN=$(aws elbv2 create-target-group --region us-east-1 --name devops90-Tg --protocol TCP --port 8002 --vpc-id $vpc_id | grep -oP '(?<="TargetGroupArn": ")[^"]*') 
       if [ "$TG_ARN" == " " ]; then
          echo "Error in Creating TG" 
          exit 1
       fi 
    else
    TG_ARN=$tg_check
    echo "TG_ARN"
    fi
    echo $TG_ARN
}
create_TG 
#create_listener
create_listener(){
    listeners_arn=$(aws elbv2 create-listener --region us-east-1 --load-balancer-arn "$LB_ARN" --protocol TCP --port 80 --default-actions Type=forward,TargetGroupArn="$TG_ARN" | grep -oP '(?<="ListenerArn": ")[^"]*')
   if [ "$listeners_arn" == "" ]; then
      echo "Failed to create listener"
      exit 1 

   fi 
   echo $listeners_arn   
    
}
create_listener
#create_autoscaling_group
create_autoscale(){
    check_asg=$(aws autoscaling describe-auto-scaling-groups --region us-east-1  --query "AutoScalingGroups[?AutoScalingGroupName == 'devops90-autoscale']"| grep -oP '(?<="AutoScalingGroupARN": ")[^"]*') 
  echo "asg will be created!"
        if [ "$check_asg" == "" ]; then
    
            aws autoscaling create-auto-scaling-group \
                --auto-scaling-group-name devops90-autoscale \
                --region us-east-1 \
                --launch-template LaunchTemplateName=srv-02 \
                --target-group-arns $TG_ARN \
                --health-check-type ELB \
                --health-check-grace-period 120 \
                --min-size 2 \
                --desired-capacity 2 \
                --max-size 5 \
                --vpc-zone-identifier "$subnets_ids"

        asg_arn=$(aws autoscaling describe-auto-scaling-groups --region us-east-1  --query "AutoScalingGroups[?AutoScalingGroupName == 'devops90-autoscale']"| grep -oP '(?<="AutoScalingGroupARN": ")[^"]*') 
        if [ "$asg_arn" == " " ]; then
            echo "Error in created SG"
            exit 1
        fi
    else
        echo "asg already exist"
        asg_arn=$check_asg
        echo $asg_arn
    fi
}
create_autoscale
#create_Scaling_poilcy
attach_scaling_policy(){
    config=$(cat << EOF
{
    "TargetValue": 10,
    "PredefinedMetricSpecification": {
         "PredefinedMetricType": "ASGAverageCPUUtilization"
    }
}
EOF
)
    config=$( echo $config | tr -d '\n' | tr -d ' ')

    aws autoscaling put-scaling-policy --auto-scaling-group-name devops90-autoscale \
  --policy-name cpu10-target-tracking-scaling-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration $config
}
attach_scaling_policy
