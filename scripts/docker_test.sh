#!/usr/bin/env bash
set -euo pipefail
docker run --rm -v "$PWD":/work -w /work ubuntu:24.04 bash -lc 'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user make && make test'
