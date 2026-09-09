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

# Install RPM Fusion repositories
sudo dnf install -y \
	"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${VERSION_ID}.noarch.rpm" \
	"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${VERSION_ID}.noarch.rpm"

# Install Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update installed packages
sudo dnf update -y --refresh

# Install Visual Studio Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo tee /etc/yum.repos.d/vscode.repo <<-'EOF' >/dev/null
	[code]
	name=Visual Studio Code
	baseurl=https://packages.microsoft.com/yumrepos/vscode
	enabled=1
	gpgcheck=1
	gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf install -y code

# Install GitHub CLI
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh

# Install Nix
curl -fsSL https://install.determinate.systems/nix | sudo bash -s -- install --no-confirm

# Install Devbox
curl -fsSL https://get.jetify.com/devbox | sudo bash -s -- -f

# Install Docker
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# Enable Docker to start at OS boot
sudo systemctl enable --now docker

# Enable Docker usage without sudo
sudo gpasswd --add "${USER}" docker

# Set up Git globally
git config --global user.name 'Hugo Marotta'
git config --global user.email 'humtta@proton.me'

git config --global user.signingkey 'humtta@proton.me'
git config --global commit.gpgsign true

git config --global core.editor 'code --wait'
git config --global init.defaultBranch 'main'

# Install Fish
sudo dnf install -y fish

# Set Fish as default shell
sudo usermod --shell "$(which fish)" "${USER}"

# Install Helium
sudo dnf copr enable -y imput/helium
sudo dnf install -y helium-bin

# Install Proton Pass
sudo dnf install -y https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm
