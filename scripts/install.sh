#!/bin/sh
# Local (non-docker) install: bats-core and its helper libraries at pinned release tags,
# unpacked into ./.bats from their GitHub release tarballs. The docker image gets the same
# three from the official bats/bats image instead.
set -eu
cd "$(dirname "$0")/.."
mkdir -p .bats
get() { # repo tag dir
  [ -d ".bats/$3" ] && return 0
  mkdir -p ".bats/$3"
  curl -fsSL "https://github.com/$1/archive/refs/tags/$2.tar.gz" | tar -xz --strip-components=1 -C ".bats/$3"
}
get bats-core/bats-core    v1.13.0 bats-core
get bats-core/bats-support v0.3.0  bats-support
get bats-core/bats-assert  v2.2.4  bats-assert
echo "bats installed: run  BATS_LIB_PATH=\$PWD/.bats .bats/bats-core/bin/bats test"
