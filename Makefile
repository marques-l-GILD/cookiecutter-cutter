# vim: ts=2 tw=2 noet ai

.DEFAULT_GOAL := help

.PHONY: help
help:               ## Show this help message
	@grep -E '^[.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN { FS = ":.*?## " }; { lines[FNR]=$$1":##"$$2; len=length($$1); if (len > max) max=len; ++c; } END { FS=":##";fmt="\033[36;1m%-"max"s\033[37;1m    %s\033[0m\n"; for(i=1;i<=c;++i){$$0=lines[i]; printf(fmt, $$1, $$2) } }'

.PHONY: clean
clean:              ## clear out build artifacts
	@rm -rf build packages

.PHONY: build
build:              ## build the package in for unix-like systems
	@scripts/build.sh

.PHONY: build-pwsh
build-pwsh:         ## build the package using powershell (can mimic windows build if you have pwsh installed)
	@if [ -z "$$PROCESSOR_ARCHITECTURE" ]; then \
	  case "$$(uname -m)" in \
	    aarch64|arm64) export PROCESSOR_ARCHITECTURE='ARM64' ;; \
	    x86_64) export PROCESSOR_ARCHITECTURE='AMD64' ;; \
	    *) echo "Assuming AMD64 architecture from: $$(uname -m)" && export PROCESSOR_ARCHITECTURE='AMD64' ;; \
	  esac; \
	fi; \
	pwsh scripts/build.ps1

.PHONY: dev
dev:                ## start a dev environment using docker and enter the shell
	@docker image rm -f cookiecutter-cutter-test:latest &>/dev/null || :
	@docker compose up -d
	@docker container exec -it cookiecutter-cutter-test bash

.PHONY: dev-down
dev-down:           ## stop the dev environment
	@docker compose down -t0
