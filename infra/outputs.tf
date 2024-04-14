output "wiz_interview_db_dns_record" {
  value = module.wiz-interview-db.public_dns
}

output "wiz_interview_db_ssh_private_key" {
  value = tls_private_key.wiz_interview_db.private_key_openssh
  sensitive = true
}

output "wiz_interview_db_login_user" {
  value = "ubuntu"
}

output "wiz_interview_db_db_user" {
  value = random_string.db_user.result
}

output "wiz_interview_db_db_password" {
  value = random_string.db_password.result
}

output "wiz_interview_db_name" {
  value = random_string.db_name.result
}

output "wiz_interview_test_machine_dns_record" {
  value = module.wiz-interview-test-machine.public_dns
}

output "wiz_interview_test_machine_private_ip" {
  value = module.wiz-interview-test-machine.private_ip
}

output "wiz_interview_test_machine_ssh_private_key" {
  value = tls_private_key.wiz_interview_test_machine.private_key_openssh
  sensitive = true
}

output "wiz_interview_test_machine_login_user" {
  value = "ubuntu"
}

output "wiz_interview_db_backup_bucket" {
  value = module.wiz-interview-db-backup-bucket.s3_bucket_id
}

output "wiz_interview_eks_cluster_name" {
  value = module.wiz-interview-eks-cluster.cluster_name
}

output "wiz_interview_eks_cluster_autoscaler_role_arn" {
  value = module.wiz-interview-eks-cluster-autoscaler-role.iam_role_arn
}
