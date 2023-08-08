#!/bin/bash
LB_ARN=$(aws elbv2 create-load-balancer --name devops-alb --type application --subnets subnet-0967ac50352da66 subnet-096ef2813d2c0b0 --security-groups sg-0bf90ea9007450e | grep -oP '(?<="LoadBalancerArn": ")[^"]*' )


echo "$LB_ARN"
 
TG_ARN=$(aws elbv2 create-target-group --name devops-tg --protocol HTTP --port 8002 --vpc-id vpc-06d67ac6585834b | grep -oP '(?<="TargetGroupArn": ")[^"]*')


echo "$TG_ARN"


aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=i-029350f3764d3ac Id=i-03d371d055ebb3


LS_ARN=$(aws elbv2 create-listener --load-balancer-arn $LB_ARN --protocol HTTP --port 8002  --default-actions Type=forward,TargetGroupArn=$TG_ARN | grep -oP '(?<="ListenerArn": ")[^"]*')


echo "$LS_ARN"


#aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
#aws elbv2 delete-target-group --target-group-arn $TG_ARN
#aws elbv2 delete-listener --listener-arn LS_ARN
