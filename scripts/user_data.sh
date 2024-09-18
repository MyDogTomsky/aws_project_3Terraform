#!/bin/bash

# Update EC2(server_manager) & Install needed Packages

sudo apt-get update
sudo apt-get install -y python3 python3-pip
sudo pip3 install boto3

# Create Group
sudo groupadd devops
sudo usermod -aG devops $USER

# Assign Ownership & Authorisation
sudo chown -R   $USER:devops  ~/scripts
sudo chmod 750 ~/scripts

sudo chmod 700 ~/scripts/migration_to_rds.sh
sudo chmod 750 ~/scripts/*.py
sudo chmod 640 ~/scripts/.env

# Execute S3 automation file & Data Migration file
python3 ~/scripts/s3_automation.py
if [ $? -ne 0 ]; then 
    echo "Execute Process Failed -> s3_automation.py" >&2
    exit 1
fi 

bash ~/scripts/migration_to_rds.sh
if [ $? -ne 0 ]; then
    echo "Execute Process Failed -> migration_to_rds.sh" >&2
    exit 1
fi   

echo "Data Migration is completed from S3 obj onto RDS."
echo "START >> Prepare LAMP stack Configuration"