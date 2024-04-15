#!/usr/bin/env bats
#
# These tests are here for informational purposes to help guide my presentation.
#
# Some of them would require Lambda-based rules that can use SSM to interrogate machine
# facts.
#
# I used the AWS Config GUI to demonstrate functionality during the presentation.

setup() {
    [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skip remaining tests"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "AWS Config rule catches that OS installed is outdated" {
  skip
}

@test "AWS Config rule catches that password authentication is enabled for the database" {
  skip
}

@test "AWS Config rule catches that database traffic is overly permissive" {
  skip
}

@test "AWS Config rule catches that database instance profile is overly permissive" {
  skip
}

@test "AWS Config rule catches that public SSH access is enabled for the database" {
  skip
}

@test "AWS Config rule catches that container image has a potentially sensitive file in it" {
  skip
}

@test "AWS Config rule catches that images are immutable in ECR" {
  skip
}

@test "AWS Config rule catches that Tasky service account is a cluster admin" {
  skip
}

@test "AWS Config rule catches that S3 bucket with database backups is world-readable" {
  skip
}
