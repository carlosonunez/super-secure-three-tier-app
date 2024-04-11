#!/usr/bin/env make
MAKEFLAGS += --silent
SHELL := /usr/bin/env bash
DOCKER_COMPOSE := $(shell which docker-compose) --progress=quiet --log-level ERROR

.PHONY: plan \
			  _init

plan: _init
plan:
	$(DOCKER_COMPOSE) run --rm terraform plan

_init: _verify_tf_state_bucket _verify_tf_state_key
	$(DOCKER_COMPOSE) run --rm terraform-init

_verify_tf_state_bucket:
	test -n "$$TERRAFORM_STATE_S3_BUCKET" && exit 0; \
	>&2 echo "ERROR: Please define TERRAFORM_STATE_S3_BUCKET"; \
	exit 1

_verify_tf_state_key:
	test -n "$$TERRAFORM_STATE_S3_KEY" && exit 0; \
	>&2 echo "ERROR: Please define TERRAFORM_STATE_S3_KEY"; \
	exit 1
