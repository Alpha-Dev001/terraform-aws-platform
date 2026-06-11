variable "project_name"          { type = string }
variable "environment"            { type = string }
variable "vpc_id"                 { type = string }
variable "public_subnet_ids"      { type = list(string) }
variable "private_subnet_ids"     { type = list(string) }
variable "web_sg_id"              { type = string }
variable "alb_sg_id"              { type = string }
variable "ec2_instance_profile"   { type = string }
variable "instance_type"          { type = string; default = "t3.micro" }
variable "min_instances"          { type = number; default = 1 }
variable "max_instances"          { type = number; default = 3 }
variable "tags"                   { type = map(string); default = {} }
