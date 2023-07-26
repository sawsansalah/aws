#create new bucket
aws s3api create-bucket --bucket devops90-cli-bucket --region eu-north-1 --create-bucket-configuration LocationConstraint=eu-north-1
note LocationConstraint -> (string)
Specifies the Region where the bucket will be created. If you don't specify a Region, the bucket is created in the US East (N. Virginia) Region (us-east-1).

#get list of all available buckets in the default region of the current user
aws s3 ls

#block all public access
aws s3api put-public-access-block --bucket devops90-cli-bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

#upload image file to the bucket
aws s3api put-object --bucket devops90-cli-bucket --content-type image/jpeg --key codeDeploy_in_action.jpg --body /mnt/c/aws/codeDeploy_in_action.jpg

#disable block public access (unblock)
aws s3api delete-public-access-block --bucket devops90-cli-bucket

#make the image file accessible for the world
aws s3api put-object-acl --bucket devops90-cli-bucket --key codeDeploy_in_action.jpg --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers

#make the image file accessible for the world
aws s3api put-object-acl --bucket devops90-cli-bucket --key codeDeploy_in_action.jpg --acl public-read

#make the image file private
aws s3api put-object-acl --bucket devops90-cli-bucket --key codeDeploy_in_action.jpg --acl private

#delete the image file
aws s3api delete-object --bucket devops90-cli-bucket --key codeDeploy_in_action.jpg

#delete the bucket
aws s3api delete-bucket --bucket devops90-cli-bucket --region eu-north-1

#get list of all available buckets in the default region of the current user
aws s3 ls
