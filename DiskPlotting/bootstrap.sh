#!/bin/bash
# Snippet stolen from https://github.com/Chia-Network/chia-blockchain/wiki/INSTALL#amazon-linux-2
# Edited to include plotman and AWS EC2 user data bootstrapping.

# Allow failures
set +e

# Install components
yum update -y
yum install python3 git python3-pip gcc python3-devel amazon-cloudwatch-agent -y

#Install pip packages needed for plotman
python3 -m pip install psutil
python3 -m pip install pyfakefs
python3 -m pip install texttable

# Setup for Chia repo
git clone https://github.com/Chia-Network/chia-blockchain.git /home/ec2-user/
# As user-data scripts are run as root, setting rights is needed.
chown -R ec2-user:ec2-user /home/ec2-user/chia-blockchain

# Setup swap file
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Setup Cloud Watch Agent

# Install Chia blockchain
sh /home/ec2-user/install.sh

# Setting up plotting drive
# Stolen from https://binx.io/blog/2019/01/26/how-to-mount-an-ebs-volume-on-nvme-based-instance-types/
# Waiting for drive mount
while [[ ! -b $(readlink -f /dev/xvdd) ]]; do
    echo "waiting for the disk to appear..">&2;
    sleep 5;
done
# Format drive only when it isn't
blkid $(readlink -f /dev/xvdd) || mkfs -t ext4 $(readlink -f /dev/xvdd)
# Mount drive
mkdir /home/ec2-user/plot
grep -q "$(readlink -f /dev/xvdd) /var/mqm " /proc/mounts || mount /home/ec2-user/plot

# Activate!
. ./activate

# Start plotting

# Copy to S3 final destination

# Self-terminate
