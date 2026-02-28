#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

###############################################################################
# Install Keybase from Official Repository
###############################################################################

echo "Installing Keybase..."

# Add Keybase RPM repository
cat > /etc/yum.repos.d/keybase.repo << 'EOF'
[keybase]
name=keybase
baseurl=http://prerelease.keybase.io/rpm/x86_64
enabled=1
gpgcheck=1
gpgkey=https://keybase.io/docs/server_security/code_signing_key.asc
metadata_expire=60
EOF

# Install Keybase
dnf5 install -y keybase

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/keybase.repo

echo "Keybase installed successfully"
