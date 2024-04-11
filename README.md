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

1. Copy `.env.example` to `.env`. Fill in anything that says
   `change_me`.

2. Deploy the app:

```sh
docker-compose run --rm deploy-app
```

This will use Terraform to create the following resources
within AWS:

- VPC
- EC2 Spot Instance
- EKS Cluster with a single EC2 Spot Worker

This will also use Ansible to:

- Install and configure the database,
- Deploy the application and its related resources into EKS
