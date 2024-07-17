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

# Essential Network Info: Create in Paris[eu-west-3]

variable "vpc_cidr"{
    default = "192.168.56.0/24"
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
    default = "192.168.56.0/27"     # 0 ~ 31
    type = string
}

variable "subnet_public2_cidr" {
    default = "192.168.56.32/28"    # 32 ~ 47
    type = string
}

variable "subnet_private_web1_cidr" {
    default = "192.168.56.96/27"   # 96 ~ 127
    type = string
}

variable "subnet_private_db1_cidr" {
    default = "192.168.56.144/28"   # 144 ~ 159
    type = string
}

variable "subnet_private_web2_cidr" {
    default = "192.168.56.192/27"   # 192 ~ 223
    type = string
}

variable "subnet_private_db2_cidr" {
    default = "192.168.56.224/28"   # 224 ~ 239
    type = string
}