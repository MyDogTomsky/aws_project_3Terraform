# Comprehensive the Resource Management

# 0. Working Status 
variable "environment" {
    default = "staging" # dev -> staging -> prod
    type = string       
}

variable "app_name" {
    default = "DynamicWebApp"
    type = string
}

# 1. Essential Network Info: Create in Paris[eu-west-3]

variable "vpc_cidr"{
    default = "172.16.33.0/24"
    type = string
}

variable "az1" {
    default = "eu-west-3a"
    type = string
}

variable "az2"{
    default = "eu-west-3b"
    type = string
}

# SUBNETS CIDR Assigned
# USING Subnet Maks /27, /28
# 27 => 32: 0,     32,     64,     96,      128,      160,      192,      224
# 28 => 16: 0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224

variable "subnet_public1_cidr" {
    default = "172.16.33.0/27"     # 0 ~ 31
    type = string
}

variable "subnet_public2_cidr" {
    default = "172.16.33.32/28"    # 32 ~ 47
    type = string
}

variable "subnet_private_web1_cidr" {
    default = "172.16.33.96/27"   # 96 ~ 127
    type = string
}

variable "subnet_private_db1_cidr" {
    default = "172.16.33.144/28"   # 144 ~ 159
    type = string
}

variable "subnet_private_web2_cidr" {
    default = "172.16.33.192/27"   # 192 ~ 223
    type = string
}

variable "subnet_private_db2_cidr" {
    default = "172.16.33.224/28"   # 224 ~ 239
    type = string
}

variable "ssh_range" {
    default = "0.0.0.0/0" 
    type = string
}

variable "all_traffic" {
    default = "0.0.0.0/0"
    type = string
}

variable "ec2_instance_class" {
    default = "t2.micro"
    type = string
}
variable "rds_username" {
    type = string
}
variable "rds_password" {
    type = string  
}
variable "rds_instance_class" {
    default = "db.t3.micro"     
    type = string
}
# db.txx series -> small scale // 
# db.mxx        -> large scale , general case
# rds info      -> secrets.tfvars


variable "snapshot_db_identifier" {
    default = "rdsdynamicwebappstaging"
    description = "Retreive Snapshot to create RDS: reference to tfstate"
    type = string
}

variable "log_bucket_tag" {
    default = "soo-log-bucket"
    description = "Log files Under dev/prod: Dynamic Web applicaiton"
    type = string
}

variable "alb_tag" {
    default = "soo-alb"
    description = "ALB name in VPC[soo]"
    type = string
}


variable "alb_acm_certificate"{
    default = "arn:aws:acm:eu-west-3:381491959817:certificate/5e60387a-ae81-4e05-a253-bd8b8e8ef455"
    description = "TLS/SSL Certificate for CNAME Record"
    type = string
}
variable "my_domain" {
    default = "mydogtomsky.com"
    description = "apex domain name"
    type = string
}

variable "ec2_template_tag" {
    default = "web_ec2_template"
    description = "value"
    type = string  
}

variable "ec2_image_id" {
    default = "ami-07ba09bac8573d1a5" # amazon linux 2023
    description = "The template Image Id for auto-scaling group"
    type = string
}
