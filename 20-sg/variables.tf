variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "development"
}

variable "common_tags" {
  default = {
    Project     = "expense"
    terraform   = "true"
    Environment = "dev"
  }
}

variable "mysql_sg_tags" {
  default = {
    component = "mysql"
  }
}

variable "control_plane_sg_tags" {
  default = {
    component = "control_plane"
  }
}

variable "node_sg_tags" {
  default = {
    component = "node"
  }
}
variable "bastion_sg_tags" {
  default = {
    component = "bastion"
  }
}

variable "ingress_alb_sg_tags" {
  default = {
    component = "ingress-alb"
  }
}
