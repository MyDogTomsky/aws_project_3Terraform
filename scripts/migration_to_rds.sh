#!/bin/bash
# Prepare Environment(Update & Flyway:download -> unzip) 

# REDHATsudo dnf update -y
# Ubuntu EC2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install wget -y
sudo apt-get install awscli -y
sudo -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/10.13.0/flyway-commandline-10.13.0-linux-x64.tar.gz | tar -xvz

# Configure Symbolic Link for Flywire to use Globally
sudo ln -s `pwd`/flyway-10.13.0/flyway  /usr/local/bin

# Retrieve Variable Value: RDS / Obj path
source .env

# Create 'migration' directory ON ec2 & Store DB obj
sudo mkdir -p migration
sudo aws s3 cp $S3_DB_URI migration/

# Reference Redgate document for Flyway to migrate data to RDS
# sql -> DATA migration by Flywire -> RDS
# Cofigure Migrate Process: Destination[RDS info],Source directory[EC2]  
cat << EOF > flyway.conf

flyway.url=jdbc:mysql://$RDS_ENDPOINT:3306/$RDS_DB_NAME
flyway.user=$RDS_DB_USERNAME
flyway.password=$RDS_DB_PASSWORD
flyway.locations=filesystem:migration
EOF

# Command Migrate process
flyway migrate