module "wiz-interview-eks-sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name = "wiz-interview-eks-sg"
  vpc_id = module.wiz-interview-vpc.vpc_id
  ingress_with_self = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_ipv6_cidr_blocks = [
    {
      from_port = -1
      to_port = -1
      protocol = "-1"
      cidr_blocks = "::/0"
    }
  ]
}

module "wiz-interview-eks-cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.8.5"
  cluster_name = "wiz-interview-cluster"
  cluster_version = "1.29"
  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  vpc_id = module.wiz-interview-vpc.vpc_id
  subnet_ids = module.wiz-interview-vpc.private_subnets
  control_plane_subnet_ids = module.wiz-interview-vpc.public_subnets
  eks_managed_node_group_defaults = {
    instance_types = [ "t4g.large" ]
  }
  enable_cluster_creator_admin_permissions = true
  eks_managed_node_groups = {
    workers = {
      min_size = 1
      max_size = 1
      desired_size = 1
      instance_types = ["t4g.large"]
      capacity_type = "SPOT"
      ami_type = "AL2_ARM_64"
    }
  }
  cluster_additional_security_group_ids = [
    module.wiz-interview-eks-sg.security_group_id
  ]
}

module "wiz-interview-eks-cluster-auth" {
  depends_on = [ module.wiz-interview-eks-cluster ]
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.8.5"

  manage_aws_auth_configmap = true

  aws_auth_users = [{
    userarn = data.aws_caller_identity.self.arn
    username = "self"
    groups = ["system:masters"]
  }]
}

module "wiz-interview-eks-cluster-autoscaler-role" {
  depends_on = [ module.wiz-interview-eks-cluster ]
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = " 5.39"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names   = [module.wiz-interview-eks-cluster.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.wiz-interview-eks-cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}
