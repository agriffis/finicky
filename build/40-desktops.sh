#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Desktop Environments Build Script
###############################################################################
# Installs additional Wayland compositors and desktop environments.
# Each desktop is kept in its own clearly-marked section so they can be
# audited, enabled, or disabled independently.
#
# Desktops included:
#   - Niri     (scrollable-tiling Wayland compositor by YaLTeR)
#   - Noctalia (shell layer for niri from Fyra Labs)
###############################################################################

# Source helper functions
# shellcheck source=build/copr-helpers.sh
source /ctx/build/copr-helpers.sh

###############################################################################
# Niri - Scrollable-tiling Wayland compositor
# https://github.com/YaLTeR/niri
###############################################################################

echo "::group:: Install Niri Wayland Compositor"

# Install niri from COPR to get the most recent release.
# The COPR yalter/niri is maintained by the upstream author and tracks
# releases faster than the Fedora stable repo.
copr_install_isolated "yalter/niri" niri

echo "::endgroup::"

echo "::group:: Install Niri Companion Tools"

# xwayland-satellite provides seamless Xwayland integration for niri,
# allowing X11 apps to run as first-class citizens inside the compositor.
# The remaining packages are the tools niri's own documentation recommends
# for a usable day-to-day setup.
dnf5 install -y \
    xwayland-satellite \
    xdg-desktop-portal-gnome \
    waybar \
    fuzzel \
    mako \
    foot \
    swaybg \
    swaylock \
    swayidle \
    grim \
    slurp \
    wl-clipboard \
    playerctl \
    brightnessctl

echo "::endgroup::"

echo "::group:: Configure Niri systemd user service"

# niri ships a systemd user service and a Wayland session .desktop file.
# We enable the user-session target so that niri's own
# niri-session.target pulls in portal and notification services
# automatically when niri starts.
#
# The graphical-session.target and xdg-desktop-portal.service are
# standard units already present on Fedora; we just make sure the
# niri-specific override directory exists so users can drop in
# additional wants without editing upstream unit files.
mkdir -p /usr/lib/systemd/user/niri-session.target.wants

# Enable the xdg-desktop-portal for all niri sessions so that
# screencasting, file-picker, and screen-share portals work out of
# the box.
systemctl --global enable xdg-desktop-portal.service

echo "::endgroup::"

###############################################################################
# Noctalia - Shell layer for niri by Fyra Labs
# https://docs.noctalia.dev/
# Noctalia provides a polished top-bar, launcher, notification daemon, and
# supporting infrastructure that turns the bare niri compositor into a
# complete desktop experience.  It is distributed through the Terra
# repository maintained by Fyra Labs.
###############################################################################

echo "::group:: Add Terra Repository"

# Terra is a community Fedora-compatible repo by Fyra Labs.
# The official installation method bootstraps the repo by installing
# terra-release from a temporary --repofrompath repo (see
# https://docs.noctalia.dev/getting-started/installation/).
# We remove the repo files afterwards so they do not persist into the
# running system (same pattern as other third-party repos in this build).
RELEASEVER=$(rpm -E '%{fedora}')
dnf5 install -y --nogpgcheck \
    --repofrompath "terra,https://repos.fyralabs.com/terra${RELEASEVER}" \
    terra-release

echo "::endgroup::"

echo "::group:: Install Noctalia Shell"

dnf5 install -y noctalia-shell

echo "::endgroup::"

echo "::group:: Remove Terra Repository"

# terra-release may drop more than one .repo file; glob to catch them all.
# Repos do not function at runtime in bootc images anyway.
rm -f /etc/yum.repos.d/terra*.repo

echo "::endgroup::"

echo "::group:: Configure Noctalia systemd user services"

# Start mako (notifications) whenever niri starts.
systemctl --global add-wants niri.service mako.service

echo "::endgroup::"

echo "Desktop build complete!"
