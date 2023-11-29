#!/bin/bash
# vim: sts=2 sw=2 et ai

set -euo pipefail

# builds a distribution of cookiecutter-cutter
main() {
  local py=""
  if hash python3 &>/dev/null; then
    py="$(command -v python3)"
  elif hash python &>/dev/null; then
    py="$(command -v python)"
  fi

  if [ -z "$py" ]; then
    die "No python interpreter found"
  fi

  info "Using python interpreter: $py"

  info "Testing that $py works"

  "$py" --help &>/dev/null || die "Python interpreter $py is not working"

  info "Using python version: $("$py" --version)"

  # ensuring a sane umask
  umask 0022

  mkdir -p build

  info "Creating virtualenv"
  "$py" -m venv build/ccc-py

  info "Activating virtualenv"
  # shellcheck disable=SC1091
  source build/ccc-py/bin/activate

  info "Validating virtualenv python installation"
  hash -r && command -v python && python --version

  info "Updating pip"
  python -m pip install --upgrade pip

  info "Installing cookiecutter"
  pip install cookiecutter

  info "Testing cookiecutter"
  cookiecutter --version

  info "Detecting architecture"

  local sys=''
  local arch=''

  sys="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$(uname -m)" in
    x86_64)        arch='amd64' ;;
    aarch64|arm64) arch='arm64' ;;
    *) die "Unsupported architecture: $(uname -m)" ;;
  esac

  if [ 'darwin' = "$sys" ]; then
    # the python interpreter installed by github actions is
    # a fat-binary/universal-binary on macOS
    #
    # `universal2` refers to the multi-arch binary format for
    # x86_64 and arm64, as opposed to the older `universal`
    # binary format for x86_64 and ppc64le
    arch='universal2'
  fi

  mkdir -p packages

  (cd build && zip -r "../packages/ccc_${sys}_${arch}.zip" ccc-py)

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "package=ccc_${sys}_${arch}.zip" >> "$GITHUB_OUTPUT"
  fi
}

info() { >&2 printf "\e[32;1m[INFO ] %s\e[0m\n" "$*"; }
die()  { >&2 printf "\e[31;1m[FATAL] %s\e[0m\n" "$*"; exit 1; }

main "$@"
