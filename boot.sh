#!/usr/bin/env bash

set -eo pipefail

# Create temporary directory
temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT

# Download repository source code
curl -fsSL https://github.com/humtta/fedora-setup/archive/refs/heads/main.tar.gz \
	| tar -xz --strip-components=1 -C "${temp_dir}"

# Run setup script
bash "${temp_dir}/setup.sh"
