#!/usr/bin/env make
MAKEFLAGS += --silent
SHELL := /usr/bin/env bash
DOCKER_COMPOSE := $(shell which docker-compose) --log-level ERROR --progress=quiet
POSTGRES_VERSION := 14

export POSTGRES_VERSION

.PHONY: dry-run deploy

dry-run: _init
	$(DOCKER_COMPOSE) run --rm terraform plan

deploy: _init
	$(DOCKER_COMPOSE) run --rm terraform apply --auto-approve=true && \
	$(DOCKER_COMPOSE) run --rm write-infra-secrets && \
	$(MAKE) configure && \
	$(MAKE) test

configure: _configure_db

test:
	$(DOCKER_COMPOSE) run --rm test-infra

teardown: _init
	$(DOCKER_COMPOSE) run --rm terraform destroy && \
	$(DOCKER_COMPOSE) run --rm delete-infra-secrets

_init:
	$(DOCKER_COMPOSE) run --rm terraform-init

_configure_db:
	$(DOCKER_COMPOSE) run --rm configure-database
