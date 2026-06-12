# ── 1. ALB SECURITY GROUP 
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allow HTTP and HTTPS from the internet to the ALB"
  vpc_id      = var.vpc_id

  # INBOUND: allow HTTP from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # 0.0.0.0/0 = the entire internet
  }

  # INBOUND: allow HTTPS from anywhere
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND: allow all outgoing traffic (the ALB needs to reach EC2)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"             # -1 means ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Allow HTTP only from the ALB; allow all outbound"
  vpc_id      = var.vpc_id

  # INBOUND: port 80 only from the ALB security group
  ingress {
    description             = "HTTP from ALB only"
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    security_groups         = [aws_security_group.alb.id]  # source = ALB SG
  }

  # INBOUND: SSH for admin access — ONLY from within the VPC (not internet)
  ingress {
    description = "SSH from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]   # only IPs inside the VPC can SSH
  }

  # OUTBOUND: allow all (servers need to pull packages, send logs, etc.)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-web-sg"
  })
}

# ── 3. IAM ROLE FOR EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach a managed policy that allows SSM Session Manager (no SSH key needed)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# An instance profile is the "wrapper" that lets an EC2 instance use an IAM role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
