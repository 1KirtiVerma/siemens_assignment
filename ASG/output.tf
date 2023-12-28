################################################################################
# Launch template
################################################################################

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.webservers.id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.webservers.arn
}


##########3 ASG #############

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = aws_autoscaling_group.webservers.id
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = aws_autoscaling_group.webservers.arn
}