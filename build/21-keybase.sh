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
#
# The RPM unpacks into /opt, which is a symlink to the machine-local /var/opt
# in bootc images, so a plain install fails (cpio: mkdir failed) and would ship
# nothing durable anyway. Install into a real /opt, relocate the payload under
# /usr/lib/opt so it travels with the image, and recreate /opt/keybase at boot
# via tmpfiles. Same treatment is needed for any other /opt RPM (Chrome,
# 1Password) — see build/20-onepassword.sh.example.
if [[ -L /opt ]]; then
    rm -f /opt
fi
mkdir -p /opt /usr/lib/opt
dnf5 install -y keybase
mv /opt/keybase /usr/lib/opt/keybase
cat > /usr/lib/tmpfiles.d/keybase.conf << 'EOF'
d /var/opt 0755 root root -
L /var/opt/keybase - - - - /usr/lib/opt/keybase
EOF

# Containerfile restores /opt as a symlink to /var/opt after the build scripts,
# so leave no stray real directory behind.
rmdir /opt

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/keybase.repo

# Disable the root redirector, becuase it's buggy and hangs the system.
# /usr/bin/keybase-redirector is a symlink into /opt/keybase, which dangles
# during the build, so operate on the relocated real path instead.
chmod a-sx /usr/lib/opt/keybase/keybase-redirector

# Disable it more, by hard masking the service
ln -sfn /dev/null /usr/lib/systemd/user/keybase-redirector.service

echo "Keybase installed successfully"
