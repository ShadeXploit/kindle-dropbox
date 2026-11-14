#!/bin/sh
# ==============================================================================
# Title:        start-alpine-dropbox.sh
# Description:  Mounts the Alpine chroot, starts Tailscale, and locks screen awake.
# ==============================================================================

# Prevent duplicate mounts if already running
if grep -q "/tmp/alpine" /proc/mounts; then
    exit 0
fi

# Give Wi-Fi a brief moment to stabilize post-boot
sleep 5

# 1. Mount the Alpine chroot image and bind essential virtual filesystems
mkdir -p /tmp/alpine
mount -o loop /mnt/us/alpine.ext3 /tmp/alpine
mount -o bind /dev /tmp/alpine/dev
mount -o bind /proc /tmp/alpine/proc
mount -o bind /sys /tmp/alpine/sys
mount -o bind /dev/pts /tmp/alpine/dev/pts
cp /etc/resolv.conf /tmp/alpine/etc/resolv.conf

# 2. Start Tailscale in userspace mode using the persistent state inside the image
chroot /tmp/alpine tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &

# 3. Brief pause for the daemon to spin up, then bring the interface online
sleep 3
chroot /tmp/alpine tailscale up

# 4. Force power daemon to keep screen and Wi-Fi awake permanently
lipc-set-prop com.lab126.powerd preventScreenSaver 1
