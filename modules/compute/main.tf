data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  
  iam_instance_profile {
    name = var.ec2_instance_profile
  }

  vpc_security_group_ids = [var.web_sg_id]

  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    # Write a simple page so we can verify the ALB works
    echo "<h1>Hello from ${var.project_name} - ${var.environment}</h1>" > /var/www/html/index.html
  EOF
  )

  # Always use the newest template version when scaling out
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project_name}-${var.environment}-web"
    })
  }
}

# ── 3. AUTO SCALING GROUP 
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-${var.environment}-asg"
  min_size            = var.min_instances
  max_size            = var.max_instances
  desired_capacity    = var.min_instances   
  vpc_zone_identifier = var.private_subnet_ids  

  # Connect the ASG to the Launch Template
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Register instances with the ALB target group automatically
  target_group_arns = [aws_lb_target_group.web.arn]

  # Replace an instance only after the new one is healthy (zero-downtime deploys)
  health_check_type         = "ELB"
  health_check_grace_period = 300  

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-web"
    propagate_at_launch = true
  }
}

# ── 4. APPLICATION LOAD BALANCER 
resource "aws_lb" "web" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false                    
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids    

  tags = var.tags
}

# ── 5. TARGET GROUP 
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2  
    unhealthy_threshold = 3   
    interval            = 30  
  }
}

# ── 6. LISTENER
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
