#!/usr/bin/env bash

set -eo pipefail

black='\e[0;30m'
blue='\e[0;34m'

red_bold='\e[1;31m'
blue_bold='\e[1;34m'

reset='\e[0m'

# Log all output to a temporary file
log_file="$(mktemp '/tmp/fedora-setup.XXXXXX.log')"
exec > >(tee "${log_file}") 2>&1

# Usage: error MESSAGE
#
# Prints MESSAGE with the prefix ERROR to stderr.
error() {
	echo -e "${red_bold}ERROR${reset} ${@}" >&2
}

# Usage: info MESSAGE
#
# Prints MESSAGE with the prefix INFO to stdout.
info() {
	echo -e "${blue_bold}INFO${reset} ${@}"
}

# Usage: abort
#
# Prints a generic error message and exits the script.
abort() {
	error "The script failed unexpectedly. For more details, check the logs in ${log_file}"
	exit 1
}

# Abort script on error
trap abort ERR

# Print header
echo
echo -e "${blue}╔═╗╔═╗╔╦╗╔═╗╦═╗╔═╗${black} ╔═╗╔═╗╔╦╗╦ ╦╔═╗${reset}"
echo -e "${blue}╠╣ ╠╣  ║║║ ║╠╦╝╠═╣${black} ╚═╗╠╣  ║ ║ ║╠═╝${reset}"
echo -e "${blue}╚  ╚═╝═╩╝╚═╝╩╚═╩ ╩${black} ╚═╝╚═╝ ╩ ╚═╝╩  ${reset}"
echo

# Load OS release information
source /etc/os-release

# Check OS compatibility
required_version='44'

if [[
	"${ID}" != 'fedora' || \
	"${VARIANT_ID}" != 'workstation' || \
	"${VERSION_ID}" != "${required_version}"
]]; then
	error "This script is intended for Fedora Workstation ${required_version} only"
	exit 1
fi

# Disable sudo timeout
info 'Disabling sudo timeout'
echo 'Defaults timestamp_timeout = -1' | sudo tee /etc/sudoers.d/timeout >/dev/null

# Remove unwanted packages
info 'Removing unwanted packages'
unwanted_packages=(
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

sudo dnf remove -y "${unwanted_packages[@]}"

# Install RPM Fusion repositories
info 'Installing RPM Fusion repositories'
sudo dnf install -y \
	"https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${VERSION_ID}.noarch.rpm" \
	"https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${VERSION_ID}.noarch.rpm"

# Install Terra repository
info 'Installing Terra repository'
sudo dnf install -y \
	--repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
	--setopt 'terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' \
	terra-release

# Install Flathub repository
info 'Installing Flathub repository'
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update installed packages
info 'Updating installed packages'
sudo dnf update -y --refresh

# Install Zed
info 'Installing Zed'
sudo dnf install -y zed

# Install GitHub CLI
info 'Installing GitHub CLI'
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install -y gh

# Install Nix
info 'Installing Nix'
curl -fsSL https://install.determinate.systems/nix | sudo bash -s -- install --no-confirm

# Install Devbox
info 'Installing Devbox'
curl -fsSL https://get.jetify.com/devbox | sudo bash -s -- -f

# Install Docker
info 'Installing Docker'
sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# Enable Docker to start at OS boot
info 'Enabling Docker to start at OS boot'
sudo systemctl enable --now docker

# Enable Docker usage without sudo
info 'Enabling Docker usage without sudo'
sudo gpasswd --add "${USER}" docker

# Install Fish
info 'Installing Fish'
sudo dnf install -y fish

# Set Fish as default shell
info 'Setting Fish as default shell'
sudo usermod --shell "$(which fish)" "${USER}"

# Install Niri and Dux Shell
info 'Installing Niri and Dux Shell'
sudo dnf install -y \
	niri \
	dms

info 'Adding Dux Shell to Niri startup'
systemctl --user add-wants niri.service dms

# Install CLI utilities
info 'Installing CLI utilities'
sudo dnf install -y \
	eza \
	bat \
	git-delta \
	direnv \
	micro \
	wl-clipboard

# Install Foot
info 'Installing Foot'
sudo dnf install -y foot

# Install Zen
info 'Installing Zen'
sudo dnf install -y zen-browser

# Install Obsidian
info 'Installing Obsidian'
sudo dnf copr enable -y kmf/Obsidian
sudo dnf install -y obsidian

# Install Proton Pass
info 'Installing Proton Pass'
sudo dnf install -y https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm

# Install Proton Authenticator
info 'Installing Proton Authenticator'
sudo dnf install -y https://proton.me/download/authenticator/linux/ProtonAuthenticator.rpm

# Install configuration files
info 'Cloning and installing configuration files'
dotfiles_repo_dir="${HOME}/Git/humtta/dotfiles"

git clone https://github.com/humtta/dotfiles "${dotfiles_repo_dir}"
bash "${dotfiles_repo_dir}/setup.sh"

# Install OpenCode Sandbox
info 'Cloning and installing OpenCode Sandbox'
ocs_repo_dir="${HOME}/Git/humtta/opencode-sandbox"

git clone https://github.com/humtta/opencode-sandbox "${ocs_repo_dir}"
ln -fs "${ocs_repo_dir}/opencode.sh" "${HOME}/.local/bin/ocs"

# Print setup completion message
echo
echo 'The script has completed successfully. Now, follow the post-installation
steps outlined at https://github.com/humtta/fedora-setup#post-installation to
complete the setup.'
