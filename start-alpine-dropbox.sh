#!/bin/sh
# ==============================================================================
# Title:        start-alpine-dropbox.sh
# Description:  Mounts the Alpine chroot, starts Tailscale, and locks screen awake.
# ==============================================================================

# 1. Ensure binds are mounted (mount if not already present)
if ! grep -q "/tmp/alpine" /proc/mounts; then
    mkdir -p /tmp/alpine
    mount -o loop /mnt/us/alpine.ext3 /tmp/alpine
    mount -o bind /dev /tmp/alpine/dev
    mount -o bind /proc /tmp/alpine/proc
    mount -o bind /sys /tmp/alpine/sys
    mount -o bind /dev/pts /tmp/alpine/dev/pts
    cp /etc/resolv.conf /tmp/alpine/etc/resolv.conf
fi

# 2. Start Tailscale if it isn't already running
if ! pgrep -f tailscaled >/dev/null; then
    echo "[*] Starting Tailscale daemon..."
    chroot /tmp/alpine tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &
    sleep 3
    chroot /tmp/alpine tailscale up
else
    echo "[*] Tailscaled is already running."
fi

# 3. Prevent screensaver/sleep to keep Wi-Fi alive
lipc-set-prop com.lab126.powerd preventScreenSaver 1
echo "[*] Drop-box is active!"
