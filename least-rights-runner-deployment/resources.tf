locals {
  premade_role = var.app_admin ? "CE_AppAdminRunner_profile" : "ce-ec2-standard-role"
}

data "aws_security_group" "standard_ec2_sg" {
  name = "ce-ec2-standard-sg"
}

data "aws_security_group" "internet_access" {
  name = "internet-access"
}

data "aws_vpc" "vpc" {
  tags = {
    Terraform_Resource = "CE_VPC"
  }
}
data "aws_subnet" "subnet1" {
  vpc_id    = data.aws_vpc.vpc.id

  tags = {
    Terraform_Resource = "CE_Subnet"
    Terraform_Role = "service"
    Terraform_ID = 1
  }
}

data "aws_subnet" "subnet2" {
  vpc_id    = data.aws_vpc.vpc.id

  tags = {
    Terraform_Resource = "CE_Subnet"
    Terraform_Role = "service"
    Terraform_ID = 2
  }
}
data "aws_security_group" "internet"  {
  vpc_id    = data.aws_vpc.vpc.id
  tags = {
    Terraform_Resource = "CE_SG"
    Terraform_Role = "Internet_Access"
  }  
}

data "aws_security_group" "ssh"  {
  vpc_id    = data.aws_vpc.vpc.id
  tags = {
    Terraform_Resource = "CE_SG"
    Terraform_Role = "SSH"
  }
}

data "aws_ami" "sanofi_amzn_2_core" {
  most_recent = true
  owners      = ["394674213819"]

  filter {
    name   = "name"
    values = ["sonic-core-amzn-2-*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/files/userdata.sh")
}

resource "aws_iam_role" "runner" {
  name                 = "App_github_roleretriever_runner"
  assume_role_policy   = file("${path.module}/files/ec2-trust.json")
  permissions_boundary = "arn:aws:iam::230559371484:policy/CE_AppAdminBoundary"
}

resource "aws_iam_role_policy" "app-roleretriever-policy" {
    name = "app-roleretriever-policy"
    role = aws_iam_role.runner.id
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAuroraToExampleFunction",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:eu-west-1:230559371484:function:App_RoleRetriever"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "standard_policy" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::230559371484:policy/ce-SanofiSSM-PolicyforEC2"
}

resource "aws_iam_instance_profile" "roleretriever" {
  name  = "App_roleretriever_profile"
  role  = aws_iam_role.runner.name
}

resource "aws_instance" "gitlab_runner" {
  ami                  = data.aws_ami.sanofi_amzn_2_core.id
  instance_type        = var.instance_type
  #user_data            = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.roleretriever.name
  subnet_id            = data.aws_subnet.subnet2.id
  key_name             = var.aws_ecs_instance_key_name

  root_block_device {
    volume_size = var.volume_size
  }
  
  vpc_security_group_ids = [
    data.aws_security_group.standard_ec2_sg.id,
    data.aws_security_group.internet_access.id,
    data.aws_security_group.ssh.id
  ]

  tags = merge(module.tagging.tags, {
    Name = var.name
  })
}

resource "aws_route53_record" "runner" {
  zone_id = var.route53_dns_zone_id
  name    = var.route53_dns_host_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.gitlab_runner.private_ip]
}
