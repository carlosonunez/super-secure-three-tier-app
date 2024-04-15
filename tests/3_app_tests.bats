#!/usr/bin/env bats

setup() {
    [ ! -f "${BATS_PARENT_TMPNAME}.skip" ] || skip "skip remaining tests"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "${BATS_PARENT_TMPNAME}.skip"
}

@test "Deploy your container-based web application to the EKS cluster" {
  run kubectl --kubeconfig /secrets/kubeconfig get pod --no-headers=true -l app=tasky -o name --field-selector=status.phase==Running
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Ensure your web application authenticates to your database server" {
  run kubectl --kubeconfig /secrets/kubeconfig exec deployment/tasky -- sh -c 'apk add --quiet --no-progress postgresql-client; psql "$POSTGRES_URI" -c "\dt"'
  [ "$status" -eq 0 ]
  results="$output"
  run grep -q 'todos' <<< "$results"
  [ "$status" -eq 0 ]
  run grep -q 'users' <<< "$results"
  [ "$status" -eq 0 ]
}

@test "Allow public internet traffic to your web application using service type loadbalancer" {
  run curl "http://$(kubectl --kubeconfig /secrets/kubeconfig get service tasky -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
  [ "$status" -eq 0 ]
  run grep -q "<title>Tasky</title>" <<< "$output"
  [ "$status" -eq 0 ]
}

@test "Configure your EKS cluster to grant cluster-admin privileges to your web application container(s)" {
  run kubectl --kubeconfig /secrets/kubeconfig get pods -l app=tasky -o jsonpath='{range .items[0]}{.spec.serviceAccountName}{end}'
  [ "$output" == 'tasky-sa' ]
  run kubectl --kubeconfig /secrets/kubeconfig get rolebinding make-tasky-sa-cluster-admin  -o jsonpath='{.roleRef.name}{"==>"}{.subjects[?(@.name=="tasky-sa")].name}'
  [ "$output" == 'cluster-admin==>tasky-sa' ]
}
