module "mysql_sg" {
  source       = "git::https://github.com/jonnadulachaitanya/terraform-aws-security-group.git?ref=main"
  Project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
  sg_name      = "mysql"
  sg_tags      = var.mysql_sg_tags
  vpc_id       = local.vpc_id
}

module "bastion_sg" {
  source       = "git::https://github.com/jonnadulachaitanya/terraform-aws-security-group.git?ref=main"
  Project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
  sg_name      = "bastion"
  sg_tags      = var.bastion_sg_tags
  vpc_id       = local.vpc_id
}

module "node_sg" {
  source       = "git::https://github.com/jonnadulachaitanya/terraform-aws-security-group.git?ref=main"
  Project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
  sg_name      = "node"
  sg_tags      = var.node_sg_tags
  vpc_id       = local.vpc_id
}

module "eks_control_plane_sg" {
  source       = "git::https://github.com/jonnadulachaitanya/terraform-aws-security-group.git?ref=main"
  Project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
  sg_name      = "eks-control-plane"
  sg_tags      = var.control_plane_sg_tags
  vpc_id       = local.vpc_id
}

module "ingress_alb_sg" {
  source       = "git::https://github.com/jonnadulachaitanya/terraform-aws-security-group.git?ref=main"
  Project_name = var.project_name
  environment  = var.environment
  common_tags  = var.common_tags
  sg_name      = "ingress-alb"
  sg_tags      = var.ingress_alb_sg_tags
  vpc_id       = local.vpc_id
}

resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb_sg.sg_id
}

resource "aws_security_group_rule" "node_accepting_from_ingress_alb" {
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 30767
  protocol                 = "tcp"
  source_security_group_id = module.node_sg.sg_id
  security_group_id        = module.node_sg.sg_id
}

resource "aws_security_group_rule" "node_accepting_from_eks_control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id        = module.node_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_accepting_from_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.node_sg.sg_id
  security_group_id        = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "node_receiving_traffic_from_vpc_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.node_sg.sg_id
}

resource "aws_security_group_rule" "node_accepting_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.node_sg.sg_id
}

resource "aws_security_group_rule" "mysql_accepting_from_nodes" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.node_sg.sg_id
  security_group_id        = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_accepting_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.mysql_sg.sg_id
}


resource "aws_security_group_rule" "bastion_accepting_from_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_accepting_from_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.eks_control_plane_sg.sg_id
}

