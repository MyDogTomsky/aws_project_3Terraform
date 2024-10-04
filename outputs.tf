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
        public_ip = aws_instance.automation_ec2.public_ip
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

# 2
output "target_group_arn"{
    value = aws_lb_target_group.alb_target_group.arn
    description = "Target Group ARN of the Load Balancer -> Health Check"
}


output "alb_metadata" {
    value = {
        load_balancer_arn = aws_lb.alb.arn,
        load_balancer_domain_name =aws_lb.alb.dns_name,
        load_balancer_meta = aws_lb.alb.tags_all,
        load_balancer_metadata_s3 = aws_s3_bucket.log_bucket.id
    }
    description = "The comprehensive Load Balancer[APPLICATION] STATE"
}
output "website_domain_name"   {
    value = aws_route53_record.a_alias.name
    description = "The Domain Name -> a-alias: www.[apex address]"
}

output "asg_template_spec" {
    value = {
    template_id = aws_launch_template.ec2_template.id,
    template_meta = aws_launch_template.ec2_template.tags_all
    template_image_id = aws_launch_template.ec2_template.image_id
    }
    description = "The template ID & Name & Environment for ASG"
}

output "asg_metadata"{
    value = {
    asg_name = aws_autoscaling_group.soo_asg.name,
    where_health_check = aws_autoscaling_group.soo_asg.health_check_type,
    desired_number_resource= aws_autoscaling_group.soo_asg.desired_capacity,
    asg_azs = aws_autoscaling_group.soo_asg.availability_zones,
    asg_subnets = aws_autoscaling_group.soo_asg.vpc_zone_identifier
    }
    description = "Auto Scaling Group comprehensive information"
}