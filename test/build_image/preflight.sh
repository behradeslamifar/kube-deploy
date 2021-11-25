#!/bin/bash

export ISO_PATH="./ubuntu-20.04-server-cloudimg-amd64.img"
export ISO_CHECKSUM="md5:804745d6a56eeff97c13cdf95dd4a88d"
export OUTPUT_NAME="ubuntu-20.04-k8s-1.22.4"

export CONTAINER_RUNTIME=containerd
export KUBE_VERSION=1.22.4-00
export DOCKER_VERSION=5:20.10.11~3-0~ubuntu-focal
export HTTP_PROXY="http://user:pass@proxy.example.com:3128/"
export NO_PROXY="localhost,127.0.0.0/8,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
export CALICO_VERSION="v3.19.1"
