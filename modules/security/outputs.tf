output "alb_sg_id"           { value = aws_security_group.alb.id }
output "web_sg_id"           { value = aws_security_group.web.id }
output "ec2_instance_profile" { value = aws_iam_instance_profile.ec2_profile.name }
