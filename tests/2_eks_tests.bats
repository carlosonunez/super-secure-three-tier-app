#!/usr/bin/env bats

setup() {
    [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skip remaining tests"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "Create an EKS cluster instance in the same VPC as your database server" {
  run aws ec2 describe-instances --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=wiz-interview-db" --query "Reservations[].Instances[].VpcId" --output text
  want="$output"
  run aws eks describe-cluster --name "wiz-interview-cluster" --query 'cluster.resourcesVpcConfig.vpcId' --output text
  got="$output"
  >&2 echo "want: $want, got: $got"
  [ "$want" == "$got" ]
}

@test "Build and host a container image for your web application" {
  run docker run --rm  -d -p 8080:80 "$(cat /secrets/ecr_repository_host)/web-app:v1"
  [ "$output" -eq 0 ]
  run curl -sS -o /tmp/page -w '%{http_code}' http://localhost:18080
  [ "$output" -eq 200 ]
  run grep -Eq '<title>Tasky</title>' /tmp/page
  [ "$status" -eq 0 ]

}
