module "vpc" {
  source                = "git::https://github.com/jonnadulachaitanya/terraform-aws-vpc..git?ref=main"
  Project_name          = var.project_name
  Environment           = var.environment
  common_tags           = var.common_tags
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  is_peering_required   = true
}
