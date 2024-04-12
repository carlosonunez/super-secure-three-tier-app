#!/usr/bin/env make
MAKEFLAGS += --silent
SHELL := /usr/bin/env bash
DOCKER_COMPOSE := $(shell which docker-compose) --log-level ERROR --progress=quiet

.PHONY: dry-run deploy

dry-run: _init
	$(DOCKER_COMPOSE) run --rm terraform plan

deploy: _init
	$(DOCKER_COMPOSE) run --rm terraform apply --auto-approve=true

teardown: _init
	$(DOCKER_COMPOSE) run --rm terraform destroy --auto-approve=true

_init:
	$(DOCKER_COMPOSE) run --rm terraform-init
