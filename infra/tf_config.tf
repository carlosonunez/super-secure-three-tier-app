terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}
provider "kubernetes" {
  host                   = module.wiz-interview-eks-cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.wiz-interview-eks-cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.wiz-interview-eks-cluster.cluster_name]
  }
}
