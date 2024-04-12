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
