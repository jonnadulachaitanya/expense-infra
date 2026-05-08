resource "aws_key_pair" "eks_key" {
  key_name = "eks-new"
  # you can paste the public key directly like this
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKr/XSGN644HTUF33kH71regpPFErI8YPIGQMR93Wgm9qWxfTDrlsttPtoxUVi6YOPkPg+px2kQ8IX+lGnIxHOURw83v+V/7uF7FwOFHmppcPfLOc0Wwmgy8pdJTnSmNs1iZEow81IJkykIn/6pSUUgnoML0ci416nDYZFS0G++YMbpCLZA7HVKhxkMhlc+cAooyXm+vq5fBrfpf/+xh8U926n83m1v2wavlxNJMVfh5YvJ+sKH3uEUQ5rl/t7SsvkNblfEf5Wb7pb2B0FyTRn5jmMNSjx7DmsMeIZkud/vxSLmEajVmvzRWYjmumRD+Elvt4/pe03oseqIk0SoK61"
  #public_key = file("F:/devops/keys/eks.pub")
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.33"

  cluster_endpoint_public_access = true

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  # custom Security Groups
  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # Modern admin access (no more old flag)
  access_entries = {
    admin = {
      principal_arn = data.aws_caller_identity.current.arn #we can use role directly

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Addons
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  # Node Group Defaults (your policy style)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"] #"m6i.large", "m5.large", "m5n.large", "m5zn.large"
    #capacity_type  = "ON_DEMAND"

    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      ElasticLoadBalancingFullAccess    = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    }
  }

  # Node Group
  eks_managed_node_groups = {
    # blue = {
    #   min_size     = 1
    #   max_size     = 1
    #   desired_size = 1

    #   key_name = aws_key_pair.eks_key.key_name

    #   tags = {
    #     Name = "blue-node"
    #   }
    # }
    green = {
      min_size     = 2
      max_size     = 10
      desired_size = 2

      key_name = aws_key_pair.eks_key.key_name

      tags = {
        Name = "green-node"
      }
    }
  }

  tags = var.common_tags
}

