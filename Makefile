include .bingo/Variables.mk

NAME := chglog
IMPORT := github.com/dronehippie/$(NAME)
SHELL := bash
BIN := bin
DIST := dist

ifeq ($(UNAME), Darwin)
	GOBUILD ?= CGO_ENABLED=0 go build -i
else
	GOBUILD ?= CGO_ENABLED=0 go build
endif

PACKAGES ?= $(shell go list ./...)
SOURCES ?= $(shell find . -name "*.go" -type f)

TAGS ?= netgo

ifndef VERSION
	ifneq ($(DRONE_TAG),)
		VERSION ?= $(subst v,,$(DRONE_TAG))
	else
		VERSION ?= $(shell git rev-parse --short HEAD)
	endif
endif

ifndef OUTPUT
	ifneq ($(DRONE_TAG),)
		OUTPUT ?= $(subst v,,$(DRONE_TAG))
	else
		OUTPUT ?= testing
	endif
endif

LDFLAGS += -s -w -extldflags "-static" -X "main.version=$(VERSION)"

.PHONY: all
all: build

.PHONY: clean
clean:
	go clean -i ./...
	rm -rf $(BIN) $(DIST)

.PHONY: fmt
fmt:
	gofmt -s -w $(SOURCES)

.PHONY: vet
vet:
	go vet $(PACKAGES)

.PHONY: staticcheck
staticcheck: $(STATICCHECK)
	$(STATICCHECK) -tags '$(TAGS)' $(PACKAGES)

.PHONY: lint
lint: $(GOLINT)
	for PKG in $(PACKAGES); do $(GOLINT) -set_exit_status $$PKG || exit 1; done;

.PHONY: test
test:
	go test -coverprofile coverage.out $(PACKAGES)

.PHONY: build
build: $(BIN)/drone-$(NAME)

$(BIN)/drone-$(NAME): $(SOURCES)
	$(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

.PHONY: release
release: $(DIST) release-linux release-reduce release-checksum

$(DIST):
	mkdir -p $(DIST)

.PHONY: release-linux
release-linux: $(DIST) \
	$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-amd64 \
	$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-5 \
	$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-6 \
	$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-7 \
	$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm64

$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-amd64:
	GOOS=linux GOARCH=amd64 $(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-5:
	GOOS=linux GOARCH=arm GOARM=5 $(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-6:
	GOOS=linux GOARCH=arm GOARM=6 $(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm-7:
	GOOS=linux GOARCH=arm GOARM=7 $(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

$(DIST)/drone-$(NAME)-$(OUTPUT)-linux-arm64:
	GOOS=linux GOARCH=arm64 $(GOBUILD) -v -tags '$(TAGS)' -ldflags '$(LDFLAGS)' -o $@ ./cmd/drone-$(NAME)

.PHONY: release-reduce
release-reduce:
	cd $(DIST); $(foreach file,$(wildcard $(DIST)/drone-$(NAME)-*),upx $(notdir $(file));)

.PHONY: release-checksum
release-checksum:
	cd $(DIST); $(foreach file,$(wildcard $(DIST)/drone-$(NAME)-*),sha256sum $(notdir $(file)) > $(notdir $(file)).sha256;)

.PHONY: release-finish
release-finish: release-reduce release-checksum
