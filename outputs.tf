# Monitor the Resources
# Manage manifest INFO

output "current_env" {
    value = var.environment
    description = "This shows the current Workload Version."
}

output "current_vpc" {
    value = aws_vpc.soo_vpc.id
    description = "It indicates the current VPC ID"
}

output "public_subnets" {
  value = [aws_subnet.subnet_public1.cidr_block,aws_subnet.subnet_public2.cidr_block]
  description = "Public Subnets CIDR"
}

output "private_az1_subnets" {
    value = [aws_subnet.subnet_private_web1.cidr_block,aws_subnet.subnet_private_db1.cidr_block]
    description = "Private Subnet AZ1: WEB1/ DB1"
}

output "eip1_az1" {
    value = aws_eip.eip_to_nat1.public_ip
    description = "If the NAT's Address in AZ1 is assigned PROPERLY." 
}

output "private_az2_subnets" {
    value = [aws_subnet.subnet_private_web2.cidr_block,aws_subnet.subnet_private_db2.cidr_block]
    description = "Private Subnet AZ2: WEB2/ DB2"
}

output "eip2_az2" {
    value = aws_eip.eip_to_nat2.public_ip
    description = "If the NAT's Address in AZ2 is assigned PROPERLY." 
}

