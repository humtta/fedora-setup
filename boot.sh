#!/usr/bin/env bash

set -eo pipefail

# Create temporary directory
temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT
