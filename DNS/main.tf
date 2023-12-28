
####Fetch ELB details using data source##33
data "aws_elb" "webservers_loadbalancer" {
  name = var.lb_name
}

#####Create Private Zone######33
resource "aws_route53_zone" "private_zone" {
  zone_id      = var.zone_id
  name         = var.zone_name
  private_zone = var.private_zone
}

###########Create DNS A record to map with LB###########
####### POINT 8 Create self signed certificate for test.example.com and used this hostname with Load balancer, this dns should be resolve internally within VPC network with route 53 private hosted zone.
resource "aws_route53_record" "dns" {
  name                             = var.dns_name
  type                             = var.type
  ttl                              = 300
  records                          = "A"

  dynamic "alias" {
######## POINT 4 The AWS generated load balancer hostname with be used for request to the public facing web application.
    content {
      name                   = data.aws_elb.webservers_loadbalancer.name
      zone_id                = data.aws_elb.webservers_loadbalancer.zone_id
      evaluate_target_health = "true"
    }
  }
}

