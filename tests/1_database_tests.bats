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
run ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -i /secrets/db_key $(cat /secrets/db_user)@$(cat /secrets/db_host) "psql postgresql://$(cat /secrets/db_db_user):$(cat /secrets/db_db_password)@localhost:5432 -c 'select now();'"
  [ "$status" -eq 0 ]
}
