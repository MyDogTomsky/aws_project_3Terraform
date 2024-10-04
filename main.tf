# VPC & NAT Gateway  
provider "aws" {
  region = "eu-west-3"  
}

resource "aws_vpc" "soo_vpc" {
  cidr_block       = var.vpc_cidr  # 172.16.33.0/24
  instance_tenancy = "default"
  tags = {
    Name = "soo_vpc"
  }
}

resource "aws_internet_gateway" "soo_igw" {
  vpc_id = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_igw"
  }
}

resource "aws_subnet" "subnet_public1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_public1_cidr

  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_public1"
  }
}
# Added Fuctionality: availability_zone & map_public_ip_on_launch

resource "aws_subnet" "subnet_public2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_public2_cidr

  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_public2"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = var.all_traffic   
    gateway_id = aws_internet_gateway.soo_igw.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table_association" "rt_in_subnet1" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rt_in_subnet2" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "subnet_private_web1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_web1_cidr
  availability_zone = var.az1

  tags = {
    Name = "subnet_private_web1"
  }
}

resource "aws_subnet" "subnet_private_web2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_db1_cidr
  availability_zone = var.az2

  tags = {
    Name = "subnet_private_web2"
  }
}

resource "aws_subnet" "subnet_private_db1" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_web2_cidr
  availability_zone = var.az1

  tags = {
    Name = "subnet_private_db1"
  }
}

resource "aws_subnet" "subnet_private_db2" {
  vpc_id     = aws_vpc.soo_vpc.id
  cidr_block = var.subnet_private_db2_cidr
  availability_zone = var.az2

  tags = {
    Name = "subnet_private_db2"
  }
}

resource "aws_eip" "eip_to_nat1" {
  domain   = "vpc"
  tags = {
    Name = "eip_to_nat1"
  }
}

resource "aws_eip" "eip_to_nat2" {
  domain   = "vpc"
  tags = {
    Name = "eip_to_nat2"
  }
}

resource "aws_nat_gateway" "soo_nat1" {
  allocation_id = aws_eip.eip_to_nat1.id
  subnet_id     = aws_subnet.subnet_public1.id

  tags = {
    Name = "soo_nat1"
  }
  depends_on = [aws_internet_gateway.soo_igw]
}

# NAT depends on IGW 
resource "aws_nat_gateway" "soo_nat2" {
  allocation_id = aws_eip.eip_to_nat2.id
  subnet_id     = aws_subnet.subnet_public2.id

  tags = {
    Name = "soo_nat2"
  }
  depends_on = [aws_internet_gateway.soo_igw]
}

resource "aws_route_table" "rt_private1" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_nat_gateway.soo_nat1.id
  }

  tags = {
    Name = "rt_private1"
  }
}

resource "aws_route_table" "rt_private2" {
  vpc_id = aws_vpc.soo_vpc.id

  route {
    cidr_block = var.all_traffic
    gateway_id = aws_nat_gateway.soo_nat2.id
  }

  tags = {
    Name = "rt_private2"
  }
}

resource "aws_route_table_association" "rt_in_web1_subnet" {
  subnet_id      = aws_subnet.subnet_private_web1.id
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table_association" "rt_in_db1_subnet" {
  subnet_id      = aws_subnet.subnet_private_db1.id
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table_association" "rt_in_web2_subnet" {
  subnet_id      = aws_subnet.subnet_private_web2.id
  route_table_id = aws_route_table.rt_private2.id
}

resource "aws_route_table_association" "rt_in_db2_subnet" {
  subnet_id      = aws_subnet.subnet_private_db2.id
  route_table_id = aws_route_table.rt_private2.id
}

# 1 Complete Basic Network Configuration

#1 Bastion SSH sg: Automation & DB migration
resource "aws_security_group" "bastion_ssh" {
  name        = "soo_bastion_sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_bastion_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.bastion_ssh.id
  cidr_ipv4         = var.ssh_range
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_outbound" {
  security_group_id = aws_security_group.bastion_ssh.id
  cidr_ipv4         = var.all_traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#2 Application Load Balancer sg
resource "aws_security_group" "load_balancer" {
  name        = "soo_alb_sg"
  description = "Allow Load Balancer[HTTP/HTTPS] inbound traffic"
  vpc_id      = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_alb_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = var.all_traffic
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = var.all_traffic
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.load_balancer.id
  cidr_ipv4         = var.all_traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 3 Web Server sg
resource "aws_security_group" "web_server" {
  name        = "soo_web_server_sg"
  description = "Allow ALB/Bastion inbound traffic to WebServer"
  vpc_id      = aws_vpc.soo_vpc.id

  tags = {
    Name = "soo_web_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_ssh" {
  security_group_id = aws_security_group.web_server.id
  referenced_security_group_id  = aws_security_group.bastion_ssh.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_http" {
  security_group_id = aws_security_group.web_server.id
  referenced_security_group_id  = aws_security_group.load_balancer.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_web_https" {
  security_group_id = aws_security_group.web_server.id
  referenced_security_group_id  = aws_security_group.load_balancer.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "webserver_outbound" {
  security_group_id = aws_security_group.web_server.id
  cidr_ipv4         = var.all_traffic
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#4 RDS instance sg

resource "aws_security_group" "rds_instance" {
  name        = "soo_rds_sg"
  description = "Allow SSH/MySQL inbound traffic to the RDS"
  vpc_id      = aws_vpc.soo_vpc.id
  tags = {
    Name = "soo_rds_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_rds" {
  security_group_id = aws_security_group.rds_instance.id

  referenced_security_group_id   = aws_security_group.bastion_ssh.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_rds" {
  security_group_id = aws_security_group.rds_instance.id

  referenced_security_group_id   = aws_security_group.web_server.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_egress_rule" "rds_outbound" {
  security_group_id = aws_security_group.rds_instance.id
  cidr_ipv4   = var.all_traffic
  ip_protocol = "-1"
   
}

# db subnet group -> db instance
# db subnet group -> db snapshot -> db instance

resource "aws_key_pair" "soo_ssh_key" {
  key_name   = "soo_ssh_key"
  public_key = file("C:\\Users\\mengu\\.ssh\\soo_ssh_key.pub")
}
resource "aws_instance" "automation_ec2" {
  ami           = data.aws_ami.instance_image_setup.id
  instance_type = var.ec2_instance_class
  vpc_security_group_ids = [aws_security_group.bastion_ssh.id]
  subnet_id = aws_subnet.subnet_public1.id
  key_name  = aws_key_pair.soo_ssh_key.key_name
  tags = {
    Name = "automation_ec2"
  }
} 

resource "aws_instance" "lamp_web_ec2" {
  ami           = data.aws_ami.instance_image_lamp.id
  instance_type = var.ec2_instance_class
  vpc_security_group_ids = [aws_security_group.web_server.id]
  subnet_id = aws_subnet.subnet_private_web1.id
  key_name  = aws_key_pair.soo_ssh_key.key_name
  tags = {
    Name = "lamp_web_ec2"
  }
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.subnet_private_db1.id, aws_subnet.subnet_private_db2.id]

  tags = {
    Name = "db_subnet_group"
  }
}
resource "aws_db_instance" "soo_rds_db" {
  allocated_storage    = 10
  db_name              = local.rds_identifier
  identifier           = local.rds_identifier
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.rds_instance_class
  username             = var.rds_username
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_instance.id]
  multi_az             = true
  skip_final_snapshot  = true
  tags = {
    Name = local.rds_identifier
    Environment = var.environment
  }
}

# 2 

# Create log file bukcet // 
# Create Target Group[with Health Check)] 
#             -->  Attach to created ALB

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_tag
  tags = {
    Name        = var.log_bucket_tag
    Environment = var.environment
  }
}
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.policy_configuration.json
}


resource "aws_lb_target_group" "alb_target_group" {
  name     = "alb-target-group"     # using (-) like S3 Bucket
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.soo_vpc.id

  health_check {
    enabled = true
    interval = 30 
    path = "/health"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 5           
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200,301,302"
  }
}

resource "aws_lb" "alb" {
  name               = var.alb_tag
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [aws_subnet.subnet_public1.id,aws_subnet.subnet_public2.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.id
    prefix  = "soo-alb-state"
    enabled = true
  }

  tags = {
    Environment = var.environment
    Name = var.alb_tag
  }
}

resource "aws_lb_listener" "https_go_alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_acm_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_listener" "http_go_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "redirect"
    
    redirect {
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
    }
  }
}

# DNS <- With A-alias record to connect with ALB
resource "aws_route53_record" "a_alias" {
  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = "www.${var.my_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

# ASG preparation
resource "aws_launch_template" "ec2_template" {

  name = "${var.environment}_${var.ec2_template_tag}"
  image_id = var.ec2_image_id
  instance_type = "t2.micro"
  key_name = aws_key_pair.soo_ssh_key.key_name
  monitoring {      
    enabled = true
  }
  vpc_security_group_ids = [aws_security_group.web_server.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}_${var.ec2_template_tag}"
      Environment = var.environment
    }
  }
/*

**  block_device_mappings { # Storage specification
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }
**  iam_instance_profile {
    name = "test"     # How to assign IAM Role
  }
**  network_interfaces {  # Configure the certain Network range 
    associate_public_ip_address = true
  }
**  user_data = filebase64("${path.module}/example.sh")
# when the instance starts, 
#           the 'user_data' is initialised for the purpose.
*/
}

resource "aws_autoscaling_group" "soo_asg" {
  vpc_zone_identifier = [aws_subnet.subnet_private_web1.id,aws_subnet.subnet_private_web2.id]  # availability_zone
  desired_capacity   = 3
  max_size           = 4
  min_size           = 2

  health_check_type = "ELB"     # ELB level >>> each EC2
  name = "${var.environment}_soo_asg"
  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}_soo_asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_to_tg" {
  autoscaling_group_name = aws_autoscaling_group.soo_asg.id
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}