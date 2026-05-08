output "ingress_alb_sg_id" {
  value = module.ingress_alb_sg.sg_id
}
output "node_sg_id" {
  value = module.node_sg.sg_id
}
output "eks_control_plane_sg_id" {
  value = module.eks_control_plane_sg.sg_id
}
output "bastion_sg_id" {
  value = module.bastion_sg.sg_id
}
output "mysql_sg_id" {
  value = module.mysql_sg.sg_id
}
