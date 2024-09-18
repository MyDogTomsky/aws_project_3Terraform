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

output "ssh_sg_id"{
    value = aws_security_group.bastion_ssh.id
    description = "Bastion SSH Security Group ID"
}

output "alb_sg_id"{
    value = aws_security_group.load_balancer.id
    description = "Load Balancer Security Group ID"
}

output "web_server_sg_id"{
    value = aws_security_group.web_server.id
    description = "Web Server Security Group ID"
}

output "db_migration_sg_id"{
    value = aws_security_group.db_migration.id
    description = "DB Migration (via Bastion) Security Group ID"
}

output "rds_sg_id"{
    value = aws_security_group.rds_instance.id
    description = "RDS instance Security Group ID"
}

output "rds_metadata" {
    value = {
        identifier = aws_db_instance.soo_rds_db.identifier,
        arn =  aws_db_instance.soo_rds_db.arn}
    description = "Check the implementation of RDS instance"
}



output "rds_endpoint" {
    value = {
        rds_identifier = aws_db_instance.soo_rds_db.identifier
        rds_endpoint = aws_db_instance.soo_rds_db.endpoint
    }
    description = "RDS info for .env -> Data Migration"
}

output "domain_automation_ec2"{
    value = {
        private_dns = aws_instance.automation_ec2.private_dns
        private_ip = aws_instance.automation_ec2.private_ip
    }
    description = "Private IP address of automtaion EC2 instance"
}

output "domain_lamp_web_ec2"{
    value = {
        private_dns = aws_instance.lamp_web_ec2.private_dns
        private_ip = aws_instance.lamp_web_ec2.private_ip
    }
    description = "Private IP address of lamp_web EC2 instance"
}