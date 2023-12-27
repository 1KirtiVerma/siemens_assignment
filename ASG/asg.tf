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