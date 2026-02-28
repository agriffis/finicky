#!/usr/bin/env bash

set -eoux pipefail

###############################################################################
# Install Keybase from Official Repository
###############################################################################
# Keybase provides an official RPM repository. Following bootc/Bluefin
# conventions, we add the repo, install, then remove the repo file so it
# does not persist into the running system.
###############################################################################

echo "::group:: Install Keybase"

# Import Keybase GPG key
rpm --import https://keybase.io/docs/server_security/code_signing_key.asc

# Add Keybase RPM repository
cat > /etc/yum.repos.d/keybase.repo << 'EOF'
[keybase]
name=keybase
baseurl=https://prerelease.keybase.io/rpm/noarch
enabled=1
gpgcheck=1
gpgkey=https://keybase.io/docs/server_security/code_signing_key.asc
EOF

# Install Keybase
dnf5 install -y keybase-client

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/keybase.repo

echo "Keybase installed successfully"

echo "::endgroup::"
