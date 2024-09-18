#   ~/.aws/credentials
aws configure
# INPUT: [Access Key, Secret Access Key] -> IAM User

# Terraform -> Initial Network Configuration
terraform plan  -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars"

####### AFTER  Finishing the Terraform Configuration
####### BEFORE Executing scripts/

# Prepare the SETUP EC2 for Configuration

####     SSH Key: Public Key Private Key    ####

# [1] SSH Key Issue: for Signature Authetication

ssh-keygen -t rsa -b 4096
                            # id_rsa    / id_rsa.pub
mv  ~/.ssh/id_rsa      ~/.ssh/soo_ssh_key
mv  ~/.ssh/id_rsa.pub  ~/.ssh/soo_ssh_key.pub


# [2] Local[pub/private key] <--> aws EC2[pub]
ssh-copy-id -i  ~/.ssh/soo_ssh_key.pub  ubuntu@ec2IPaddress
# In EC2, ~/.ssh/authorized_keys  PLACED!

# [3] SSH Access Configuration: vi ~/.ssh/config

Host            setup_manager
HostName        ubuntu EC2 Domain IP
User            ubuntu
IdentityFile    ~/.ssh/soo_ssh_key    

# [4] Transfer Directory Using SSH scp function.

scp -r  scripts  setup_manager:~/
ssh setup_manager
sudo chown -R $USER:$USER ~/scripts
sudo find ~/scripts -name "user_data.sh" -exec sudo chmod 700 {}\;

bash ~/scripts/user_data.sh