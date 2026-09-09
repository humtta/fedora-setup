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

# Remove unwanted packages
UNWANTED_PACKAGES=(
	baobab
	firefox*
	gnome-calendar
	gnome-characters
	gnome-clocks
	gnome-color-manager
	gnome-connections
	gnome-contacts
	gnome-font-viewer
	gnome-logs
	gnome-maps
	gnome-shell-extension-apps-menu
	gnome-shell-extension-background-logo
	gnome-shell-extension-launch-new-instance
	gnome-shell-extension-places-menu
	gnome-shell-extension-window-list
	gnome-system-monitor
	gnome-tour
	gnome-weather
	ibus-anthy*
	ibus-hangul
	ibus-libpinyin
	ibus-m17n
	ibus-typing-booster
	libreoffice*
	simple-scan
	snapshot
	yelp*
)

sudo dnf remove -y "${UNWANTED_PACKAGES[@]}"
