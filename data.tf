# EC2[for Migration] AMI info
 
data "aws_ami" "instance_image_setup" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "instance_image_lamp" {
  most_recent = true
# id = ami-0cb0b94275d5b4aec
  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.20240916.0-kernel-6.1-x86_64"]
  }
  

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon Linux 2023
}

# 2
data "aws_db_snapshot" "snapshot_for_rds" {
  db_instance_identifier = var.snapshot_db_identifier
  most_recent            = true
  snapshot_type          = "manual"         
  }
# To Retrieve the snapshot, which is prepared manually and most recently.    


data "aws_route53_zone" "domain_name" {
  name         = var.my_domain    
  private_zone = false
}
# #apex domain / public DNS(route53)


data "aws_elb_service_account" "main" {}
data "aws_iam_policy_document" "policy_configuration" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.log_bucket.arn,
      "${aws_s3_bucket.log_bucket.arn}/*",
    ]
  }
}
