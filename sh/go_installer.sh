#!/bin/bash

ARCH=$(uname -m)
url=""
archive=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [[ "$ARCH" == "x86_64" ]]; then
    latest_version=$(wget -qO- https://go.dev/dl/ | grep -Eo '/dl/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -1)
    url="https://go.dev${latest_version}"
    archive=${latest_version:4}
  elif [[ "$ARCH" == "aarch64" ]]; then
    latest_version=$(wget -qO- https://go.dev/dl/ | grep -Eo '/dl/go([0-9\.]+)\.linux-arm64\.tar\.gz' | head -1)
    url="https://go.dev${latest_version}"
    archive=${latest_version:4}
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ "$ARCH" == "x86_64" ]]; then
    latest_version=$(wget -qO- https://go.dev/dl/ | grep -Eo '/dl/go([0-9\.]+)\.darwin-amd64\.tar\.gz' | head -1)
    url="https://go.dev${latest_version}"
    archive=${latest_version:4}
  elif [[ "$ARCH" == "aarch64" ]]; then
    latest_version=$(wget -qO- https://go.dev/dl/ | grep -Eo '/dl/go([0-9\.]+)\.darwin-arm64\.tar\.gz' | head -1)
    url="https://go.dev${latest_version}"
    archive=${latest_version:4}
  fi
fi

wget --quiet --continue --show-progress "${url}"

# Remove Old Go
sudo rm -rf /usr/local/go

# Install New Go
sudo tar -C /usr/local -xzf $archive

rm $archive
unset GOLANG

echo 'PATH=$PATH:/usr/local/go/bin' >>~/.profile
echo 'GOPATH=$HOME/golang' >>~/.profile

source ~/.profile

which go
go version

cd ~

mkdir golang
mkdir golang/src
