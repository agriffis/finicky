#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

###############################################################################
# Install Tailscale from Official Repository
###############################################################################

echo "Installing Tailscale..."

# Add Tailscale RPM repository
RELEASEVER=$(rpm -E '%{fedora}')
cat > /etc/yum.repos.d/tailscale.repo << EOF
[tailscale-stable]
name=Tailscale stable
baseurl=https://pkgs.tailscale.com/stable/fedora/${RELEASEVER}/\$basearch
enabled=1
type=rpm
repo_gpgcheck=1
gpgcheck=1
gpgkey=https://pkgs.tailscale.com/stable/fedora/${RELEASEVER}/repo.gpg
EOF

# Install Tailscale
dnf5 install -y tailscale

# Enable the tailscaled daemon so it starts on boot
systemctl enable tailscaled

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/tailscale.repo

echo "Tailscale installed successfully"
