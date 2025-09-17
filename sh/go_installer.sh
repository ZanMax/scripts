#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

ARCH=$(uname -m)
echo "Detected OS: $OSTYPE"
echo "Detected arch: $ARCH"

# helper to fetch URL body (wget or curl)
fetch_body() {
  local url=$1
  if command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
  elif command -v curl >/dev/null 2>&1; then
    curl -sL "$url"
  else
    echo "Need wget or curl. Install one and re-run." >&2
    exit 1
  fi
}

# determine pattern based on OS/arch
case "$OSTYPE" in
  linux-gnu*)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
      PATTERN='/dl/go[0-9]+\.[0-9]+(\.[0-9]+)?\.linux-amd64\.tar\.gz'
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
      PATTERN='/dl/go[0-9]+\.[0-9]+(\.[0-9]+)?\.linux-arm64\.tar\.gz'
    else
      echo "Unsupported architecture: $ARCH" >&2
      exit 1
    fi
    ;;
  darwin*)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
      PATTERN='/dl/go[0-9]+\.[0-9]+(\.[0-9]+)?\.darwin-amd64\.tar\.gz'
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
      PATTERN='/dl/go[0-9]+\.[0-9]+(\.[0-9]+)?\.darwin-arm64\.tar\.gz'
    else
      echo "Unsupported architecture: $ARCH" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported OS: $OSTYPE" >&2
    exit 1
    ;;
esac

echo "Fetching latest Go release info..."
latest_path=$(fetch_body "https://go.dev/dl/" | grep -Eo "$PATTERN" | head -n1 || true)
if [[ -z "${latest_path:-}" ]]; then
  echo "Failed to determine latest Go download URL." >&2
  exit 1
fi

url="https://go.dev${latest_path}"
archive=$(basename "$latest_path")
latest_tag=$(echo "$archive" | grep -Eo 'go[0-9]+\.[0-9]+(\.[0-9]+)?')

echo "Latest Go: $latest_tag"
echo "Download URL: $url"

# check installed version
if command -v go >/dev/null 2>&1; then
  installed_tag=$(go version | awk '{print $3}')
  if [[ "$installed_tag" == "$latest_tag" ]]; then
    echo "Go $installed_tag is already installed. Nothing to do."
    exit 0
  else
    echo "Installed: $installed_tag    -> Will install: $latest_tag"
  fi
else
  echo "Go not installed. Will install: $latest_tag"
fi

# download (wget preferred because it shows progress)
echo "Downloading $archive ..."
if command -v wget >/dev/null 2>&1; then
  wget --continue --show-progress -O "$archive" "$url"
else
  curl -L --fail -o "$archive" "$url"
fi

# require sudo/root to install to /usr/local
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO='sudo'
  else
    echo "This script needs sudo to install to /usr/local. Run as root or install sudo." >&2
    exit 1
  fi
else
  SUDO=''
fi

echo "Removing old /usr/local/go (if any)..."
$SUDO rm -rf /usr/local/go

echo "Extracting $archive to /usr/local ..."
$SUDO tar -C /usr/local -xzf "$archive"

echo "Cleaning up archive..."
rm -f "$archive"

# ensure PATH and GOPATH lines exist (idempotent)
PROFILE="${HOME}/.profile"

if ! grep -qxF 'export PATH=$PATH:/usr/local/go/bin' "$PROFILE" 2>/dev/null; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> "$PROFILE"
fi

if ! grep -qxF 'export GOPATH=$HOME/go' "$PROFILE" 2>/dev/null; then
  echo 'export GOPATH=$HOME/go' >> "$PROFILE"
fi

# apply immediately in this shell
source "$PROFILE"

# create GOPATH dirs
mkdir -p "$GOPATH"/{bin,pkg,src}

echo "✅ Installation complete."
echo "Run 'source ~/.profile' in new shells to activate Go in PATH."
echo
echo "Installed Go version:"
go version
