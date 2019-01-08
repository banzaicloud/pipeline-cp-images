BASE_NAME ?=pipeline-cp-image

GIT_REV=$(shell git rev-parse --short HEAD)
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
#GIT_TAG=$(shell git describe --exact-match --tags 2>/dev/null )

AWS_IMAGE_NAME ?= $(BASE_NAME)-$(GIT_BRANCH)-${GIT_REV}-$(shell date +%y%m%d%H%M)

ENVS=AWS_IMAGE_NAME=$(AWS_IMAGE_NAME)

.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets.)

.PHONY: list
list:
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

show-image-name:
	@echo AWS_IMAGE_NAME=$(AWS_IMAGE_NAME)

build-aws-ubuntu-xenial:
	$(ENVS) \
	./scripts/packer.sh build $(PACKER_OPTS)

inspect:
	$(ENVS) \
	./scripts/packer.sh inspect

show-image-tags:
	@echo AWS_IMAGE_NAME=$(AWS_IMAGE_NAME)