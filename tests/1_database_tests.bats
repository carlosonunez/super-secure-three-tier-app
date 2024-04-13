#!/usr/bin/env bats

setup() {
    [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skip remaining tests"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "Ensure database host secret exists" {
  run grep -Eq 'compute.amazonaws.com' /secrets/db_host
  [ "$status" -eq 0 ]
}

@test "Ensure database secret exists" {
  run cat /secrets/db_user
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Ensure database user exists" {
  run cat /secrets/db_db_user
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Ensure database user password exists" {
  run cat /secrets/db_db_password
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Ensure database SSH key secret exists" {
  run grep -Eq 'BEGIN (OPENSSH|RSA) PRIVATE KEY' /secrets/db_key
  [ "$status" -eq 0 ]
}

@test "Create a Linux EC2 instance on which a database server is installed" {
  run aws ec2 describe-instances --filter 'Name=tag:Name,Values=wiz-interview-db' --query 'Reservations[0].Instances[0].InstanceId' --output text
  [ "$status" -eq 0 ]
}

@test "Configure a security group to allow SSH from the public Internet" {
  run nc -w 3 -z $(cat /secrets/db_host) 22
  [ "$status" -eq 0 ]
}

@test "Configure the database with authentication" {
  run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/db_key $(cat /secrets/db_user)@$(cat /secrets/db_host) "psql postgresql://$(cat /secrets/db_db_user):$(cat /secrets/db_db_password)@localhost/$(cat /secrets/db_name) -c 'select now();'"
  [ "$status" -eq 0 ]
}

# Doesn't necessarily have to be from our database instance...
@test "Allow DB traffic to originate only from your VPC" {
  # So start a service pretending to be a database on a test machine...
  run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/test_machine_key $(cat /secrets/test_machine_user)@$(cat /secrets/test_machine_host) 'pkill -i -9 nc; nohup nc -l 0.0.0.0 5432 > /dev/null 2>&1 &'
  [ "$status" -eq 0 ]
  # ...and see if we can connect to it from our real database (or anywhere else within the VPC)
  run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/db_key $(cat /secrets/db_user)@$(cat /secrets/db_host) 'nc -w 3 -z '"$(cat /secrets/test_machine_private_ip)"' 5432'
  [ "$status" -eq 0 ]
}

@test "Database instance should have a script that backs up to an S3 bucket" {
  previous_num_backups=$(aws s3 ls s3://$(cat /secrets/db_backup_bucket) | wc -l)
  run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/db_key $(cat /secrets/db_user)@$(cat /secrets/db_host) '/usr/local/bin/backup_database.sh'
  [ "$status" -eq 0 ]
  curr_num_backups=$(aws s3 ls s3://$(cat /secrets/db_backup_bucket) | wc -l)
  [ "$curr_num_backups" -eq "$((previous_num_backups+1))" ]
}

@test "Configure the DB to regularly & automatically backup to your exercise S3 Bucket" {
  run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/db_key $(cat /secrets/db_user)@$(cat /secrets/db_host) 'set -x; sudo crontab -l | grep -Eq "^0 \* \* \* \* /usr/local/bin/backup_database.sh$"'
  [ "$status" -eq 0 ]
}

@test "Configure your bucket such that the public can read and download objects from it" {
  run echo 'hello' > /tmp/test_file
  [ "$status" -eq 0 ]
  run aws s3 cp /tmp/test_file s3://$(cat /secrets/db_backup_bucket)/test_file
  [ "$status" -eq 0 ]
  run curl -o /dev/null -w '%{http_code}' -sS https://$(cat /secrets/db_backup_bucket).s3.$AWS_DEFAULT_REGION.amazonaws.com/test_file
  [ "$output" -eq 200 ]
}
