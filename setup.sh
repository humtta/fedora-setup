#!/usr/bin/env bash

set -eo pipefail

# Load OS release information
source /etc/os-release

# Check OS compatibility
REQUIRED_VERSION='44'

if [[
	"${ID}" != 'fedora' || \
	"${VARIANT_ID}" != 'workstation' || \
	"${VERSION_ID}" != "${REQUIRED_VERSION}"
]]; then
	echo "Error: this script is intended for Fedora Workstation ${REQUIRED_VERSION} only" >&2
	exit 1
fi

# Disable sudo timeout
echo 'Defaults timestamp_timeout = -1' | sudo tee /etc/sudoers.d/timeout >/dev/null
