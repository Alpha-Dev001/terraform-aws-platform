variable "aws_region"           { type = string }
variable "project_name"         { type = string }
variable "environment"          { type = string }
variable "vpc_cidr"             { type = string }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "instance_type"        { type = string }
variable "min_instances"        { type = number }
variable "max_instances"        { type = number }
variable "enable_versioning"    { type = bool }
variable "tags"                 { type = map(string); default = {} }
