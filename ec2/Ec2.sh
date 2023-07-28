#create key
aws ec2 create-key-pair --key-name devops90-cli-key --key-format ppk --query 'KeyMaterial' --output text > devops90-cli-key.ppk


#create security group
aws ec2 create-security-group --group-name devops90-sg --description 'from cli' --query 'GroupId'


#sg-03edc296191a2dcb0


#add rule
aws ec2 authorize-security-group-ingress --group-id sg-03edc296191a2dcb0 --protocol tcp --port 22 --cidr 102.57.118.81/32
aws ec2 authorize-security-group-ingress --group-id sg-03edc296191a2dcb0 --protocol tcp --port 80 --cidr 102.57.118.81/32


# Create EC2 instance
aws ec2 run-instances \
    --image-id ami-09e1162c87f73958b \
    --count 1 \
    --instance-type t3.micro \
    --key-name devops90-cli-key \
    --region eu-north-1 \
    --security-group-ids sg-03edc296191a2dcb0 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=env,Value=devops},{Key=name,Value=devops-cli}]"



aws ec2 terminate-instances --instance-ids i-0c031f241ec7fb582
aws ec2 delete-security-group --group-id sg-03edc296191a2dcb0