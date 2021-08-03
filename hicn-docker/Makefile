# We want to use bash
SHELL:=/bin/bash

# Default target, no other targets should be before default
.PHONY: default
default: all

# Include Makefiles
include base/Makefile.base
#include docker/allinone/Makefile.allinone
include two/Makefile.two
include three/Makefile.three
include four/Makefile.four
include network/Makefile.network
include srv6/Makefile.srv6
include test/Makefile.test

# Setup proxies for docker build
ifeq ($(HTTP_PROXY),)
HTTPBUILD=
else
HTTPBUILD=--build-arg HTTP_PROXY=$(HTTP_PROXY)
endif
ifeq ($(HTTPS_PROXY),)
HTTPSBUILD=
else
HTTPSBUILD=--build-arg HTTPS_PROXY=$(HTTPS_PROXY)
endif

DOCKERBUILD=docker build ${HTTPBUILD} ${HTTPSBUILD}

# The StrongSwan repository and commit to use
#BA_STRONGSWAN_REPO_URL=https://github.com/mestery/strongswan.git
#BA_STRONGSWAN_COMMIT=vpp-1810

.PHONY: all check docker-build
#
# The all target is what is used by the travis-ci system to build the Docker images
# which are used to run the code in each run.
#
all: check docker-build

check:
	@shellcheck `find . -name "*.sh"`

#docker-build: docker-build-allinone docker-build-multiple docker-build-strongswan docker-build-vppvpn docker-build-cups-vppvpn
#docker build: docker-build-two docker-build-three docker-build-network

# Travis
#.PHONY: travis
#travis:
#	@echo "=> TRAVIS: $$TRAVIS_BUILD_STAGE_NAME"
#	@echo "Build: #$$TRAVIS_BUILD_NUMBER ($$TRAVIS_BUILD_ID)"
#	@echo "Job: #$$TRAVIS_JOB_NUMBER ($$TRAVIS_JOB_ID)"
#	@echo "AllowFailure: $$TRAVIS_ALLOW_FAILURE TestResult: $$TRAVIS_TEST_RESULT"
#	@echo "Type: $$TRAVIS_EVENT_TYPE PullRequest: $$TRAVIS_PULL_REQUEST"
#	@echo "Repo: $$TRAVIS_REPO_SLUG Branch: $$TRAVIS_BRANCH"
#	@echo "Commit: $$TRAVIS_COMMIT"
#	@echo "$$TRAVIS_COMMIT_MESSAGE"
#	@echo "Range: $$TRAVIS_COMMIT_RANGE"
#	@echo "Files:"
#	@echo "$$(git diff --name-only $$TRAVIS_COMMIT_RANGE)"

#.PHONY: run
#run: run-allinone run-multiple run-strongswan run-vppvpn run-cups-vppvpn
#run: run-two run-three

#.PHONY: test
#test: test-allinone test-multiple test-strongswan test-vppvpn test-cups-vppvpn
#test: test-two
