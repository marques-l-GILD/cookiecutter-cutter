#!/bin/bash
# vim: sw=2 sts=2 et ai

set -euo pipefail

# Set the repository owner and name
OWNER="your-github-username"
REPO="your-repository-name"

main() {
  # Determine OS and architecture
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$(uname -m)" in
    x86_64)        ARCH='amd64' ;;
    aarch64|arm64) ARCH='arm64' ;;
    *) die "Unsupported architecture: $(uname -m)" ;;
  esac

  if [ 'darwin' = "$OS" ]; then
    ARCH='universal2'
  fi

  # Get the latest release asset download URL for the current OS and architecture
  ASSET_URL=$(curl -s https://api.github.com/repos/$OWNER/$REPO/releases/latest | grep "browser_download_url" | grep "$OS" | grep "$ARCH" | cut -d '"' -f 4)

  # Download and unzip the asset
  curl -L "$ASSET_URL" -o latest_release.zip

    # Perform a SHA-256 check on the downloaded file
  if [ 'darwin' = "$OS" ]; then
    SHASUM=$(shasum -a 256 latest_release.zip | awk '{ print $1 }')
  else
    SHASUM=$(sha256sum latest_release.zip | awk '{ print $1 }')
  fi
  echo "SHA-256 checksum: $SHASUM"

  unzip latest_release.zip -d ~/bin

  # Clean up
  rm latest_release.zip
}

info() { >&2 printf "\e[32;1m[INFO ] %s\e[0m\n" "$*"; }
die()  { >&2 printf "\e[31;1m[FATAL] %s\e[0m\n" "$*"; exit 1; }

main "$@"
