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
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# Setup Cloud Watch Agent


# Setup plotting drive


# Install Chia blockchain
sh /home/ec2-user/install.sh

# Activate!
. ./activate


