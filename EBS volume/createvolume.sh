# create volume 

aws ec2 create-volume \
    --region us-east-1 \
    --availability-zone us-east-1a\
    --volume-type io2 \
    --size 12 \
    --iops 6000\
    --tag-specifications 'ResourceType=volume,Tags=[{Key=purpose,Value=production},{Key=cost-center,Value=cc123}]'
#Attatch volume 

aws ec2 attach-volume  --region us-east-1   --volume-id vol-0cfa184fbef5ec423 --instance-id i-05cad470fe1e2a997 --device /dev/sdf

# use Doucmentation to add ext4
   lsblk
    sudo mkfs -t ext4 /dev/xvdf
     sudo mkdir /data
     sudo mount /dev/xvdf /data
     df -h

# sudo fio --name=write_iops  --size=4G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=16k --iodepth=256 --rw=randwrite --group_reporting=1  --iodepth_batch_submit=256  --iodepth_batch_complete_max=256
#  sudo fio --name=write_iops  --size=4G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 --verify=0 --bs=1M --iodepth=256 --rw=randwrite --group_reporting=1  --iodepth_batch_submit=256  --iodepth_batch_complete_max=256
