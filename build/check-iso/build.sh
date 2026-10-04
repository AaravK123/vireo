#!/usr/bin/env bash
# Builds the Vireo Check ISO. Run inside a Debian 13 VM:  sudo ./build.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/../.."                 # the top vireo/ folder
WORK=/var/tmp/vireo-check          # messy build files live here, not in the repo

rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"

# 1. Basic settings: Debian 13, 64-bit, ISO that boots on old BIOS and new UEFI PCs
lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer none \
  --apt-recommends false \
  --memtest none \
  --bootappend-live "boot=live components quiet" \
  --iso-application "Vireo Check" \
  --iso-volume "VIREO-CHECK" \
  --image-name "vireo-check"

# 2. Extra programs
mkdir -p config/package-lists
cp "$HERE/packages.list" config/package-lists/vireo.list.chroot

# 3. Our files, placed inside the USB's system
INC=config/includes.chroot
mkdir -p $INC/opt/vireo $INC/etc/profile.d
cp "$ROOT/edition-check/check-edition.sh" "$ROOT/edition-check/thresholds.conf" $INC/opt/vireo/
chmod +x $INC/opt/vireo/check-edition.sh
cp "$HERE/login-hook.sh" $INC/etc/profile.d/vireo-check.sh

# 4. Build, then copy the ISO to your home folder
lb build
cp "$WORK"/*.iso "/home/${SUDO_USER:-root}/"
chown "${SUDO_USER:-root}" /home/${SUDO_USER:-root}/*.iso
echo "Done. Your ISO is in your home folder."