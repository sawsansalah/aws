#!/bin/bash

LB_ARN=$(aws elbv2 create-load-balancer --name alb-load-balancer --subnets subnet-0d70a375b4296b56a  subnet-059fed4186cfc49f4 --type application --security-group sg-07f5be9356c3e8f85 | grep -oP '(?<="LoadBalancerArn": ")[^"]*')

echo $"LB_ARN"

TG_ARN=$(aws elbv2 create-target-group --name my-targets --protocol HTTP  --port 8002 --target-type instance --vpc-id vpc-088dce8f2ac33af28 | grep -oP '(?<="TargetGroupArn": ")[^"]*')
echo $"TG_ARN"

aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=i-056eacfcbe12bfbf0 Id=i-091053b795c8b790f

LS_ARN=$(aws elbv2 create-listener --load-balancer-arn $LB_ARN --protocol HTTP --port 8002 --default-actions Type=forward,TargetGroupArn=$TG_ARN | grep -oP '(?<="ListenerArn": ")[^"]*')
echo "$LS_ARN"


   

    
