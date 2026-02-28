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
#   - Niri   (scrollable-tiling Wayland compositor by YaLTeR)
#   - Noctua (Wayfire-based compositor with a nocturnal/dark aesthetic)
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
# Noctua - Dark-aesthetic Wayfire-based Wayland compositor
# https://github.com/WayfireWM/wayfire
# Noctua installs Wayfire together with the wcm configuration manager and
# a curated set of plugins that together form the "noctua" experience:
# smooth animations, a dark panel, and a tiling layout plugin.
###############################################################################

echo "::group:: Install Noctua (Wayfire) Compositor"

# Wayfire and its companion config manager (wcm) are in the Fedora repos;
# the COPR repo by the upstream author ships newer snapshots when needed.
copr_install_isolated "soreau/wayfire" \
    wayfire \
    wayfire-plugins-extra \
    wcm

echo "::endgroup::"

echo "::group:: Install Noctua Companion Tools"

# waybar, mako, and the screenshot/wallpaper stack are shared with Niri
# above; dnf5 is idempotent so reinstalling them is harmless.  We list
# the Wayfire-specific extras separately so the intent is clear.
dnf5 install -y \
    wf-shell \
    xdg-desktop-portal-wlr

echo "::endgroup::"

echo "::group:: Configure Noctua systemd user service"

# Enable the wlr portal so that screencasting works in Wayfire sessions.
systemctl --global enable xdg-desktop-portal-wlr.service

echo "::endgroup::"

echo "Desktop build complete!"
