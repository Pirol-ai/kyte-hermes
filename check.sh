#!/usr/bin/env bash
# Prove the catalog entry works, without touching the Hermes you actually use.
#
# Everything happens in a throwaway directory: its own HERMES_HOME (so no
# config of yours is read or written), its own HOME (so ${HOME} in the
# manifest resolves into the sandbox), and this repo as the catalog. The
# script lists the entry, installs it, and connects to the server.
#
# It needs the `hermes` and `kyte` commands on the PATH. kyte does not have to
# be signed in: without a session the server offers one tool that says so,
# which is itself the thing worth seeing.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
mkdir -p "$sandbox/home" "$sandbox/fakehome"

run() { env HOME="$sandbox/fakehome" HERMES_HOME="$sandbox/home" \
  HERMES_OPTIONAL_MCPS="$here/optional-mcps" PATH="$PATH" hermes "$@"; }

echo "── the entry is in the catalog"
run mcp catalog | grep -q '^  kyte ' || { echo "FAIL: kyte not listed"; exit 1; }

echo "── it installs"
printf 'y\n' | run mcp install kyte >/dev/null

echo "── the data folder is its own, and left for kyte to expand"
grep -q -- '- ~/.kyte/hermes' "$sandbox/home/config.yaml" \
  || { echo "FAIL: data folder not written as ~/.kyte/hermes"; exit 1; }

echo "── it connects and serves tools"
run mcp test kyte | tee "$sandbox/test.out" | grep -q '✓ Connected' \
  || { echo "FAIL: no connection"; exit 1; }
grep -q 'Tools discovered' "$sandbox/test.out" || { echo "FAIL: no tools"; exit 1; }

echo
echo "✓ catalog entry works"
sed -n '/Tools discovered/,$p' "$sandbox/test.out"
