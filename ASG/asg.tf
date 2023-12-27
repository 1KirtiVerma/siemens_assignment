data "aws_vpc" "vpc" {
filter {
    name   = "Environment"
    values = ["dev"]
  }
}

data "aws_subnet" "public_subnet" {
filter {
    name   = "Environment"
    values = ["dev"]
  }
}

data "aws_subnet" "private_subnet" {
filter {
    name   = "Environment"
    values = ["dev"]
  }
}

# Load Balancer Security Group 

resource "aws_security_group" "loadbalancer-sg" { 
    name = "loadbalancer-sg" 
    description = "Security group for the load balancer" 
    ingress { 
        from_port = 80 
        to_port = 80 
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"] 
        } 
        
        ingress { 
            from_port = 443 
            to_port = 443 
            protocol = "tcp" 
            cidr_blocks = ["0.0.0.0/0"] 
            } 
            
        egress { 
            from_port = 0 
            to_port = 0 
            protocol = "-1" 
            cidr_blocks = ["0.0.0.0/0"] 
            } 
            } 
            # Instance Security Group 
            resource "aws_security_group" "instance-sg" { 
                name = "instance-sg" 
                description = "Security group for instances" 
                ingress { 
                    from_port = 80 
                    to_port = 80 
                    protocol = "tcp" 
                    security_groups = [aws_security_group.loadbalancer-sg.id] 
                    } 
                    
                ingress { 
                    from_port = 443 
                    to_port = 443 
                    protocol = "tcp" 
                    security_groups = [aws_security_group.loadbalancer-sg.id] 
                    } 
                    
                    # Add any additional ports for management purposes... 
                egress { 
                    from_port = 0 
                    to_port = 0 
                    protocol = "-1" 
                    cidr_blocks = ["0.0.0.0/0"] 
                    } 
                } 

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
  instance_type = var.instance_type

   block_device_mappings {
    device_name = "/dev/xvda"  # Root Volume

    ebs {
      volume_size           = 30
      volume_type = "gp2"
      encrypted             = true
      delete_on_termination = true
    }
  }

   block_device_mappings {
    device_name = "/var/log"

    ebs {
      volume_size           = 100
      volume_type = "gp2"
      encrypted             = true
      delete_on_termination = true
    }
  }
}
resource "aws_autoscaling_group" "webservers" {
  availability_zones = var.availability_zones
  vpc_zone_identifier = data.aws_subnet.private_subnet.id
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  launch_template {
    id      = aws_launch_template.webservers.id
    version = "$Latest"
  }
  
  depends_on = [
    aws_elb.webservers_loadbalancer
  ]
}
resource "aws_elb" "webservers_loadbalancer" {
  name               = var.name
  availability_zones = var.availability_zones
  security_groups = [aws_security_group.loadbalancer-sg.id] 
  subnets = data.aws_subnet.public_subnet.id  # Need to add data source

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