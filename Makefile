#!/usr/bin/env make
MAKEFLAGS += --silent
SHELL := /usr/bin/env bash
DOCKER_COMPOSE := $(shell which docker-compose) --log-level ERROR --progress=quiet
POSTGRES_VERSION := 14
TASKY_REPO_URL := https://github.com/carlosonunez/tasky
TASKY_VERSION := main

export POSTGRES_VERSION
export TASKY_REPO_URL
export TASKY_VERSION

.PHONY: dry-run deploy

dry-run: _init
	$(DOCKER_COMPOSE) run --rm terraform plan

deploy:
	$(MAKE) deploy-infra && \
	$(MAKE) configure && \
	$(MAKE) test

deploy-infra: _init
	$(DOCKER_COMPOSE) run --rm terraform apply --auto-approve=true && \
	$(DOCKER_COMPOSE) run --rm write-infra-secrets && \
	$(DOCKER_COMPOSE) run --rm refresh-eks-kubeconfig

deploy-app:
	$(DOCKER_COMPOSE) run --rm deploy-app

configure:
	$(DOCKER_COMPOSE) run --rm configure-infra

test:
	$(DOCKER_COMPOSE) run --rm test

teardown: _init
	$(DOCKER_COMPOSE) run --rm terraform destroy && \
	$(DOCKER_COMPOSE) run --rm delete-infra-secrets

_init:
	$(DOCKER_COMPOSE) run --rm terraform-init
