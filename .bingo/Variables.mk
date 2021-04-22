# Auto generated binary variables helper managed by https://github.com/bwplotka/bingo v0.4.0. DO NOT EDIT.
# All tools are designed to be build inside $GOBIN.
BINGO_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GOPATH ?= $(shell go env GOPATH)
GOBIN  ?= $(firstword $(subst :, ,${GOPATH}))/bin
GO     ?= $(shell which go)

# Below generated variables ensure that every time a tool under each variable is invoked, the correct version
# will be used; reinstalling only if needed.
# For example for bingo variable:
#
# In your main Makefile (for non array binaries):
#
#include .bingo/Variables.mk # Assuming -dir was set to .bingo .
#
#command: $(BINGO)
#	@echo "Running bingo"
#	@$(BINGO) <flags/args..>
#
BINGO := $(GOBIN)/bingo-v0.4.0
$(BINGO): $(BINGO_DIR)/bingo.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/bingo-v0.4.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=bingo.mod -o=$(GOBIN)/bingo-v0.4.0 "github.com/bwplotka/bingo"

GOLINT := $(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5
$(GOLINT): $(BINGO_DIR)/golint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=golint.mod -o=$(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5 "golang.org/x/lint/golint"

REFLEX := $(GOBIN)/reflex-v0.3.0
$(REFLEX): $(BINGO_DIR)/reflex.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/reflex-v0.3.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=reflex.mod -o=$(GOBIN)/reflex-v0.3.0 "github.com/cespare/reflex"

STATICCHECK := $(GOBIN)/staticcheck-v0.2.0-0.dev.0.20210416150052-89cc18af8fe1
$(STATICCHECK): $(BINGO_DIR)/staticcheck.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/staticcheck-v0.2.0-0.dev.0.20210416150052-89cc18af8fe1"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=staticcheck.mod -o=$(GOBIN)/staticcheck-v0.2.0-0.dev.0.20210416150052-89cc18af8fe1 "honnef.co/go/tools/cmd/staticcheck"

