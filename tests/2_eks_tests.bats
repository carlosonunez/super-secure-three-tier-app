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
  docker rm -f tasky || true
  run docker run -e MONGODB_URI=mongodb://foo --rm --name tasky -d -p 8080:8080 "$(cat /secrets/ecr_repository_host)"
  [ "$status" -eq 0 ]
  run nc -w 5 -z host.docker.internal 8080
  [ "$status" -eq 0 ]
  run curl -sS -o /tmp/page -w '%{http_code}' http://host.docker.internal:8080
  [ "$output" -eq 200 ]
  run grep -Eq '<title>Tasky</title>' /tmp/page
  [ "$status" -eq 0 ]
  run docker rm -f tasky
}

@test "Ensure your built container image contains an arbitrary file called “wizexercise.txt” with some content" {
  run docker run -e MONGODB_URI=mongodb://foo --rm --name tasky -d -p 8080:8080 "$(cat /secrets/ecr_repository_host)"
  [ "$status" -eq 0 ]
  run docker exec tasky stat /wizexercise.txt
  [ "$status" -eq 0 ]
}

@test "Deploy your container-based web application to the EKS cluster" {
  run kubectl --kubeconfig /secrets/kubeconfig get pod --no-headers=true -l app=tasky -o name --field-selector=status.phase==Running
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}
