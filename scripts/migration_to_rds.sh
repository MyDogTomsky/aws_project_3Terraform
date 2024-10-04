#!/bin/bash
# Prepare Environment(Update & Flyway:download -> unzip) 

# REDHATsudo dnf update -y
# Ubuntu EC2
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install wget -y
sudo wget -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/10.13.0/flyway-commandline-10.13.0-linux-x64.tar.gz | tar -xvz

# Configure Symbolic Link for Flywire to use Globally
sudo ln -s `pwd`/flyway-10.13.0/flyway  /usr/local/bin

# Retrieve Variable Value: RDS 
source .env

# Create 'migration' directory ON ec2 & Store DB obj
sudo mkdir -p migration
sudo chmod 777 migration
aws s3 cp "s3://soo-dynamicweb-bucket/V1__shopwise_db.sql" migration/
#sudo mv migration/shopwise_db.sql migration/V1__shopwise_db.sql

# Reference Redgate document for Flyway to migrate data to RDS
# sql -> DATA migration by Flywire -> RDS
# Cofigure Migrate Process: Destination[RDS info],Source directory[EC2]

# .env 를 source .env로 가져오는 과정을 알기 위해서 << EOF > flyway.conf EOF를 생략하고 바로 사용해보기
# .env는 적용 후에 사용해야하는 것이 맞는 것인가? 
cat << EOF > flyway.conf

flyway.url=jdbc:mysql://$RDS_ENDPOINT:3306/
flyway.user=$RDS_DB_USERNAME
flyway.password=$RDS_DB_PASSWORD
flyway.locations=filesystem:migration
flyway.defaultSchema=$RDS_DB_NAME
EOF

# Command Migrate process
flyway migrate