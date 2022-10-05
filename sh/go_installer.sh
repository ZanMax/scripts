#!/bin/bash

# ARM
export GOLANG="$(curl -s https://go.dev/dl/ | awk -F[\>\<] '/linux-arm64/ && !/beta/ {print $5;exit}')"
wget https://golang.org/dl/$GOLANG
sudo tar -C /usr/local -xzf $GOLANG
rm $GOLANG
unset GOLANG

echo 'PATH=$PATH:/usr/local/go/bin' >> ~/.profile
echo 'GOPATH=$HOME/golang' >> ~/.profile

source ~/.profile

which go
go version

cd ~

mkdir golang
mkdir golang/src
