#   ~/.aws/credentials -> For IAM User Configuration
aws configure

# Terraform -> Initial Network Configuration
terraform plan  -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"

####### AFTER  Finishing the Terraform Configuration
####### BEFORE Executing scripts/

# Prepare the SETUP EC2 for Configuration
####     SSH Key: Public Key Private Key    ####

# [0] SSH Key Issue: for Signature Authetication
ssh-keygen -t rsa -b 4096
                            # id_rsa    / id_rsa.pub
mv  ~/.ssh/id_rsa      ~/.ssh/soo_ssh_key
mv  ~/.ssh/id_rsa.pub  ~/.ssh/soo_ssh_key.pub
#ssh-copy-id -i  ~/.ssh/soo_ssh_key.pub  ubuntu@ec2IPaddress

## When Creating EC2, the Private Key is PLACED in EC2 >> ~/.ssh/authorized_keys 

# [1] SSH key is placed in AutomationEC2(Bastion)

# WINDOW -> Ubuntu(~/.ssh/[PrivateKey])
# [1-1] Private Key is sent to the Bastion EC2 to connect with WEB server, DB server
scp -i "PrivateKeyPath" "PrivateKeyPath"  ubuntu@PublicIPaddress
#      (Authentication)   (FileToSend)     User @ HostPublicIP
sudo chown $USER:$USER ~/.ssh/[PrivateKey]
sudo chmod 600 ~/.ssh/[PrivateKey]

# [2] Transfer Automation Directorys Using scp(SSH) function.
 
scp -i "WINDOW' PrivateKeyPath" -r scripts  ubuntu@PublicIP:~/
ssh -i "PrivateKeyPath" ubuntu@Bastion_PublicIP
sudo chown -R $USER:$USER ~/scripts
sudo find ~/scripts -name "user_data.sh" -exec sudo chmod 700 {} \;


# [3] Bastion Server Essential Configuration
###### Essential Linux Env & Packages(aws cli ...)
sudo apt update
sudo apt upgrade -y
sudo apt install -y wget unzip git curl
# Install awscli 
curl    -> .zip 
unzip   -> .zip
sudo ./aws/install
# Authorisation Configuration on Bastion EC2
aws configure   ->  IAM configuration: Access KEYs in ~/.aws/credentials

# [4] User & Group 

sudo groupadd devops
sudo usermod -aG devops $USER
# to APPLY
sudo reboot 

bash ~/scripts/user_data.sh

## Make SSH ACCESS EASY >>
# [3] SSH Access Configuration: vi ~/.ssh/config To LAMP server

Host            e.g.setup_manager
HostName        PrivateIP
User            ec2-user
IdentityFile    ~/.ssh/soo_ssh_key    