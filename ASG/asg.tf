########## VPC Data source####
data "aws_vpc" "vpc" {
  filter {
    name   = "Environment"
    values = ["dev"]
  }
}

########Public Subnet DataSource ###
data "aws_subnet" "public_subnet" {
  filter {
    name   = "Environment"
    values = ["dev"]
  }
}

##########Private Subnet Datasource###########
data "aws_subnet" "private_subnet" {
  filter {
    name   = "Environment"
    values = ["dev"]
  }
}

# Load Balancer Security Group 
############# POINT 3  Assuming that the end-users only contact the load balancers and the underlying instance are accessed for management purposes, design a security group scheme which supports the minimal set of ports required for communication
resource "aws_security_group" "loadbalancer-sg" {
  name        = "loadbalancer-sg"
  description = "Security group for the load balancer"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance Security Group 
resource "aws_security_group" "instance-sg" {
  name        = "instance-sg"
  description = "Security group for instances"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer-sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer-sg.id]
  }

  # Add any additional ports for management purposes... 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########## POINT 5 An autoscaling group should be created which utilizes the latest AWS AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["jboss-*"]
  }
  owners = ["137112412989"] # Account details
}

resource "aws_launch_template" "webservers" {
  name_prefix   = var.name_prefix
  image_id      = data.aws_ami.amazon_linux.id
  user_data_base64  = base64encode(data.local_file.user_data.rendered)
  instance_type = var.instance_type
########### POINT 6 The instance in the ASG Must contain both a root volume to store the application / services and must contain a secondary volume meant to store any log data bound from / var/log

  block_device_mappings {
    device_name = "/dev/xvda" # Root Volume

    ebs {
      volume_size           = 30
      volume_type           = "gp2"
      encrypted             = true
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/var/log"

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      encrypted             = true
      delete_on_termination = true
    }
  }
}

#### AutoScaling Group ##########
#### POINT 6 Must include a web server of your choice.
resource "aws_autoscaling_group" "webservers" {
  availability_zones  = var.availability_zones
  #### POINT 1 It must include a VPC which enables future growth / scale ######
  ##### POINT 2 It must include both a public and private subnet – where the private subnet is used for compute
  vpc_zone_identifier = data.aws_subnet.private_subnet.id
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  launch_template {
    id      = aws_launch_template.webservers.id
    version = "$Latest"
  }

  depends_on = [
    aws_elb.webservers_loadbalancer
  ]
}

############ Load Balancer ############
resource "aws_elb" "webservers_loadbalancer" {
  name               = var.name
  availability_zones = var.availability_zones
  security_groups    = [aws_security_group.loadbalancer-sg.id]
  #######POINT 2 and the public is used for the load balancers
  subnets            = data.aws_subnet.public_subnet.id

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }
}

######## User DATA #########
####POINT 7  all requirements in this task of configuring the operating system should be defined in the launch configuration and/or the user data script

data "local_file" "user_data" {
  filename = "../userdata.tpl"
}