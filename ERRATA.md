# Okay, so this app isn't secure at all

Here's a list of insecurities introduced into this stack.

## Git

- No `.gitignore` despite an `.env` file being present and this repo being
  hosted on a public GitHub instance. Can potentially leak credentials into the
  world. Encrypt the `.env` or use a credential manager.
- Commits not signed. Can result in commit tampering similar to the 2024 `xz`
  supply chain attack and various NPM attacks in 2021. Use PGP with GPG or SSH
  keys to sign commits.

## EC2

- `root` SSH login enabled. DDoS attack and intrusion vector (the Internet
  slamming the host with failed login attempts).
- `ec2::*` allowed on IAM EC2 Instance Profile. Widens attack surface by
  allowing anyone logged into instance to do anything on EC2. Only allow EC2 API
  calls needed by the database, remove the Instance Profile if none needed or
  use a managed service that has more built-in database security. (This is also
  cheaper.)
- EBS volume is unencrypted. Data loss risk medium. Use KMS to encrypt the
  volume.
- Database backups unencrypted. Data loss risk high (especially given
  `public-read` on the S3 bucket). Use GPG or similar to encrypt the backups.

## EC2 Networking

- SSH wide open to the public Internet. DDoS and brute force attack vectors.
  Only allow SSH within VPC.
- Web server on the same network segment as database. Wide attack surface with
  high risk of data loss. Separate each tier into separate segments.

## EKS/Kubernetes/Containers

- Image on Docker Hub. High data risk loss, especially given the arbitrary file
  present. Host on a private registry only accessible to EKS cluster.
- Raw connection string in codebase. Credential stealing risk high. Use
  Kubernetes secrets, a configuration service or a credential manager.
- Connecting as `pgadmin`. Data loss risk high. Use a service account with
  least-privileged access to tables/databases.
- Containers created with `cluster-admin` `ServiceAccount`s. Privilege
  escalation risk high while widening attack surface (Kubernetes stores
  `ServiceAccount` tokens on disk using projected volumes). Use a namespaced
  `ServiceAccount` (default is fine).
- Container forks application as `root` superuser. Privilege escalation risk
  high given the container's long lifetime. (A user can elevate the container to
  a privileged container and break out into the worker node via `kubectl exec`.)
  Create and use a least-privileged user, and use it to fork the application
  with.

## S3

- Bucket has open `public-read` privileges. Data loss risk high. Use a bucket
  policy to allow specific files to be read or, better, disable `public-read`
  and modify Instance Profile for database to only allow
  `s3::{Get,List,Put}Object` API calls for just this bucket.
