output "wiz_interview_db_dns_record" {
  value = aws_instance.wiz_interview_db.public_dns
}

output "wiz_interview_db_ssh_private_key" {
  value = tls_private_key.wiz_interview_db.private_key_openssh
  sensitive = true
}
