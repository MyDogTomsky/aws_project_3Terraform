#!/bin/bash

# Amazon Linux: RedHat type

sudo dnf update -y
sudo dnf install -y httpd

sudo dnf install -y wget php php-fpm php-mysqli php-json 
sudo dnf install -y php-devel php-mbstring php-xml
sudo dnf install -y mariadb105-server

sudo dnf info httpd php* mariadb*
sudo systemctl start  httpd mariadb
sudo systemctl enable httpd mariadb

# Configure Apache Web Server Authorisation 
# To use [Group] Apache Web server by awscli user

sudo usermod -aG apache $USER
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www

sudo find /var/www -type d -exec sudo chmod 2775 {}\;
sudo find /var/www -type f -exec sudo chmod 0664 {}\;

# MySQL(Secure DB:MariaDB & Enable) 
sudo mysql_secure_installation
sudo systemctl enable mariadb

# Install A DB Management Tool[PhpMyAdmin] & Restart Apache & MariaDB
sudo systemctl restart httpd php-fpm
cd /var/www/html

sudo mkdir phpMyAdmin
sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
sudo tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1

sudo rm phpMyAdmin-latest-all-languages.tar.gz
sudo systemctl restart mariadb

# Modify Apache Web Server Configuration ->.htaccess

sudo sed -i '/<Directory "\/var\/www\/html">/,/<\Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf



# Deploy Web files to Apache Server

aws s3 sync s3://soo-dynamicweb-bucket /var/www/html
cd /var/www/html
sudo unzip shopwise.zip -d shopwise-temp
sudo cp -R shopwise-temp/.  /var/www/html
sudo rm-rf shopwise-temp shopwise.zip

sudo find /var/www/html -type d -exec sudo chmod 2775 {} \;
sudo find /var/www/html -type f -exec sudo chmod 0664 {} \;

sudo vi .env
# update app_url/app_env my domain name RDS -> CONFIGURATION
# /var/www/html/app/Providers/AppServiceProvider.php -> forceUrl to HTTPS, SSL, PROXY_HEADER)
sudo service httpd restart