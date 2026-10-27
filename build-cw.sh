#!/usr/bin/env bash
# Reproducible release build of this fork (noeljackson/task, branch
# fix-advisories). Upstream v3.54.0 with only its Go toolchain and the
# golang.org/x modules moved to releases that carry the advisory fixes.
#
# The same commit gives byte-identical binaries on any Linux or macOS host:
# - the toolchain is the official go1.27.3, which `go` downloads and checks
#   against sum.golang.org (GOTOOLCHAIN; go.mod's toolchain line names it);
# - modules come from go.sum, read-only (-mod=readonly), through the default
#   checksum database;
# - no cgo, -trimpath, no VCS stamp and an empty build ID, so neither the
#   host, the checkout path nor the clone's state reaches the binary.
#
# Usage: ./build-cw.sh OUT_DIR
# Writes task_<os>_<arch> for linux/amd64, linux/arm64 and darwin/arm64, and
# SHA256SUMS beside them.
set -euo pipefail
out="${1:?usage: build-cw.sh OUT_DIR}"
mkdir -p "$out"
export GOTOOLCHAIN=go1.27.3 CGO_ENABLED=0 GOFLAGS=-mod=readonly GOPROXY=https://proxy.golang.org GOSUMDB=sum.golang.org
cd "$(dirname "$0")"
go version
for target in linux/amd64 linux/arm64 darwin/arm64; do
  GOOS="${target%/*}" GOARCH="${target#*/}" go build -trimpath -buildvcs=false \
    -ldflags='-s -w -buildid=' -o "$out/task_${target%/*}_${target#*/}" ./cmd/task
done
(cd "$out" && sha256sum task_* > SHA256SUMS && cat SHA256SUMS)
