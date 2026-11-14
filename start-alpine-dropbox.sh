#!/bin/sh
# ==============================================================================
# Title:        start-alpine-dropbox.sh
# Description:  Mounts Alpine chroot, starts Tailscale, and handles auth if needed.
# ==============================================================================

# 1. Mount the Alpine chroot if not already mounted
if ! grep -q "/tmp/alpine" /proc/mounts; then
    echo "[*] Mounting Alpine filesystem and binds..."
    mkdir -p /tmp/alpine
    mount -o loop /mnt/us/alpine.ext3 /tmp/alpine
    mount -o bind /dev /tmp/alpine/dev
    mount -o bind /proc /tmp/alpine/proc
    mount -o bind /sys /tmp/alpine/sys
    mount -o bind /dev/pts /tmp/alpine/dev/pts
    cp /etc/resolv.conf /tmp/alpine/etc/resolv.conf
fi

# 2. Start tailscaled daemon if it isn't already running
if ! pgrep -f tailscaled >/dev/null; then
    echo "[*] Starting Tailscale daemon..."
    chroot /tmp/alpine tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &
    sleep 3
fi

# 3. Check if Tailscale is authenticated; if not, trigger interactive login
echo "[*] Checking Tailscale connection status..."
if chroot /tmp/alpine tailscale status | grep -q "LoggedOut\|NeedsLogin\|Stopped"; then
    echo ""
    echo "--------------------------------------------------------"
    echo "[!] Tailscale needs authentication!"
    echo "[!] Please open the login URL below on your phone or PC:"
    echo "--------------------------------------------------------"
    echo ""
    # Run interactively so the login URL is printed directly to your terminal
    chroot /tmp/alpine tailscale up --ssh --tun=userspace-networking
else
    echo "[*] Tailscale is already connected and active."
    chroot /tmp/alpine tailscale up --tun=userspace-networking >/dev/null 2>&1
fi

# 4. Force power daemon to keep screen and Wi-Fi awake permanently
lipc-set-prop com.lab126.powerd preventScreenSaver 1
echo "[*] Drop-box is fully running and power-lock is active."
