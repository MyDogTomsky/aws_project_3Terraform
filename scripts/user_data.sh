#!/bin/bash

# Update EC2(server_manager) & Install needed Packages
#                           IN Virtual Env for python packages
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
python3 -m pip config set global.break-system-packages true
#python3 -m venv $HOME/tempenv
#source $HOME/tempenv/bin/activate

#인지 아니면 virtual env를 한건지 확인하기


# Assign Ownership & Authorisation
sudo chown -R   $USER:devops  ~/scripts
sudo chmod 750 ~/scripts

sudo chmod 700 ~/scripts/migration_to_rds.sh
sudo chmod 750 ~/scripts/*.py
sudo chmod 640 ~/scripts/.env

# Activate Python Virtual ENV, install BOTO3 & execute --->
# Execute S3 automation file & Data Migration file

#source $HOME/tempenv/bin/activate
pip install --upgrade pip
pip install boto3

python3 ~/scripts/s3_automation.py
if [ $? -ne 0 ]; then 
    echo "Execute Process Failed -> s3_automation.py" >&2
    exit 1
fi 
#deactivate

bash ~/scripts/migration_to_rds.sh
if [ $? -ne 0 ]; then
    echo "Execute Process Failed -> migration_to_rds.sh" >&2
    exit 1
fi   

echo "Data Migration is completed from S3 obj onto RDS."
echo "START >> Prepare LAMP stack Configuration"