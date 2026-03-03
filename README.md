# finicky

A custom bootc operating system image based on the lessons from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io), built from the [finpilot](https://github.com/projectbluefin/finpilot) template.

This image uses the **multi-stage build architecture** from @projectbluefin/distroless, combining resources from multiple OCI containers for modularity and maintainability.

## What's in finicky?

Here are the changes from the base silverblue-main image. This image uses Bluefin's build patterns (silverblue-main + GNOME) and includes these customizations:

### Added packages (build-time)
- **Core Tools** (`10-build.sh`): gnome-pomodoro, kitty, et, neovim, stow, syncthing
- **Networking** (`20-tailscale.sh`): Tailscale VPN client with tailscaled daemon
- **Security** (`21-keybase.sh`): Keybase encrypted messaging and filesystem
- **Wayland Compositors** (`40-desktops.sh`): 
  - Niri (scrollable-tiling compositor from COPR yalter/niri)
  - Mango (MangoWM compositor from Terra repository)
  - Noctalia Shell (niri shell layer from Terra repository)
- **Desktop Helpers** (`40-desktops.sh`): brightnessctl, kanshi, playerctl, wayland-utils, wev, wl-clipboard, wlr-randr, xdg-desktop-portal-gnome, xdg-desktop-portal-wlr, xwayland-satellite

### Added applications (runtime)
- **CLI Tools (Homebrew)**: None added yet — see `custom/brew/default.Brewfile` to add CLI tools
- **GUI Apps (Flatpak)**: None added yet — see `custom/flatpaks/default.preinstall` to add GUI apps

### Configuration changes
- Uses `@projectbluefin/common` desktop configuration shared with Bluefin/Aurora
- Homebrew integration via `@ublue-os/brew`

### Production features
- (TODO) SBOM generation (Software Bill of Materials) for supply chain transparency
- Image signed with cosign for cryptographic verification
- Automated security updates via Renovate
- Build provenance tracking

Users can verify images with:
```bash
cosign verify --key cosign.pub ghcr.io/your-username/your-repo-name:stable
```

## Development workflow

All changes should be made via pull requests:

1. Open a pull request on GitHub with the change you want.
3. The PR will automatically trigger:
   - Build validation
   - Brewfile, Flatpak, Justfile, and shellcheck validation
   - Test image build
4. Once checks pass, merge the PR
5. Merging triggers publishes a `:stable` image

### Local testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Deployment

Switch to finicky:

```bash
sudo bootc switch ghcr.io/agriffis/finicky:stable
sudo systemctl reboot
```

## Architecture

This template follows the **multi-stage build architecture** from @projectbluefin/distroless, as documented in the [Bluefin Contributing Guide](https://docs.projectbluefin.io/contributing/).

### Multi-stage build pattern

**Stage 1: Context (ctx)** - Combines resources from multiple sources:
- Local build scripts (`/build`)
- Local custom files (`/custom`)
- **@projectbluefin/common** - Desktop configuration shared with Aurora
- **@projectbluefin/branding** - Branding assets
- **@ublue-os/artwork** - Artwork shared with Aurora and Bazzite
- **@ublue-os/brew** - Homebrew integration

**Stage 2: Base Image** - Default options:
- `ghcr.io/ublue-os/silverblue-main:latest` (Fedora-based, default)
- `quay.io/centos-bootc/centos-bootc:stream10` (CentOS-based alternative)

### Benefits of this architecture

- **Modularity**: Compose your image from reusable OCI containers
- **Maintainability**: Update shared components independently
- **Reproducibility**: Renovate automatically updates OCI tags to SHA digests
- **Consistency**: Share components across Bluefin, Aurora, and custom images

### OCI container resources

The template imports files from these OCI containers at build time:

```dockerfile
COPY --from=ghcr.io/ublue-os/base-main:latest /system_files /oci/base
COPY --from=ghcr.io/projectbluefin/common:latest /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /oci/brew
```

Your build scripts can access these files at:
- `/ctx/oci/base/` - Base system configuration
- `/ctx/oci/common/` - Shared desktop configuration
- `/ctx/oci/branding/` - Branding assets
- `/ctx/oci/artwork/` - Artwork files
- `/ctx/oci/brew/` - Homebrew integration files

**Note**: Renovate automatically updates `:latest` tags to SHA digests for reproducible builds.

### Detailed guides

- [Homebrew/Brewfiles](custom/brew/README.md) - Runtime package management
- [Flatpak Preinstall](custom/flatpaks/README.md) - GUI application setup
- [ujust Commands](custom/ujust/README.md) - User convenience commands
- [Build Scripts](build/README.md) - Build-time customization

## References

- [Original README in this repo](https://github.com/agriffis/finicky/blob/8a0a23192706dca82d31eb1245e4b4757303adb9/README.md)
- [Remaining TODO from original README](https://github.com/agriffis/finicky/blob/main/TODO.md)
- [Universal Blue Documentation](https://universal-blue.org/)
- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Documentation](https://containers.github.io/bootc/)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

