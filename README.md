# Extremely Secure™ Three Tier App

![](./assets/app.png)

## Summary

This codebase deploys an example of an extremely secure three-tier web app.
There are no misconfigurations or vulnerabilities in this codebase.

Absolutely none.

Don't poke around trying to find any either.

## Running It Locally

```sh
docker-compose up -d app
```

This will start the application and its database.

## Deploying Into AWS

> 💸 **MONEY WARNING**: This will cost you ~USD $0.50/hr.

1. `export` the following values into your environment:

- `TERRAFORM_STATE_S3_BUCKET`: The name of the bucket to store Terraform state
  into.
- `TERRAFORM_STATE_S3_KEY`: The name of the key within the bucket above to store
  state into.

2. Log into AWS and ensure the following environment variables are exported:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (if using AWS STS)

3. Deploy the app:

```sh
make deploy
```

This will use Terraform to create the following resources
within AWS:

- VPC
- EC2 Spot Instance
- EKS Cluster with a single EC2 Spot Worker

This will also use Ansible to:

- Install and configure the database,
- Deploy the application and its related resources into EKS
