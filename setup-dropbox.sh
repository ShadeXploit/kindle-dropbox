#!/bin/sh
# ==============================================================================
# Title:        setup-dropbox.sh
# Description:  Bootstrap installer for the Kindle Alpine Tailscale Drop-Box.
# Prerequisite: Jailbroken Kindle with terminal/jobman access.
# ==============================================================================

echo "[*] Setting up Alpine drop-box environment..."

# 1. Verify alpine.ext3 is present on user storage
if [ ! -f /mnt/us/alpine.ext3 ]; then
    echo "[!] Error: alpine.ext3 not found in /mnt/us/. Please copy your image over first."
    exit 1
fi

# 2. Create the working runtime directory
mkdir -p /tmp/alpine

# 3. Mount the image loopback style and bind filesystems
echo "[*] Mounting Alpine filesystem and binds..."
mount -o loop /mnt/us/alpine.ext3 /tmp/alpine
mount -o bind /dev /tmp/alpine/dev
mount -o bind /proc /tmp/alpine/proc
mount -o bind /sys /tmp/alpine/sys
mount -o bind /dev/pts /tmp/alpine/dev/pts
cp /etc/resolv.conf /tmp/alpine/etc/resolv.conf

# 4. Bootstrap packages inside the chroot if not already installed
echo "[*] Installing required packages inside chroot (Tailscale, curl, bash)..."
chroot /tmp/alpine apk update
chroot /tmp/alpine apk add tailscale curl bash htop

echo "[*] Setup complete! You can now run your start script via:"
echo "    sh /mnt/us/start-alpine-dropbox.sh"
