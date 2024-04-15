#!/usr/bin/env bats

setup() {
    [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skip remaining tests"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "Create an S3 Bucket to hold your database backups" {
  run aws s3 ls s3://$(cat /secrets/db_backup_bucket)
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
