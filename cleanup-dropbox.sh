#!/bin/sh
# ==============================================================================
# Title:        cleanup-dropbox.sh
# Description:  Removes the Alpine chroot, unmounts binds, and restores the 
#               Kindle to a clean, standard jailbroken state.
# ==============================================================================

echo "[*] Starting Kindle drop-box teardown..."

# 1. Safely unmount active chroot binds and loop device if mounted
if grep -q "/tmp/alpine" /proc/mounts; then
    echo "[*] Unmounting active chroot directories..."
    umount /tmp/alpine/dev/pts 2>/dev/null
    umount /tmp/alpine/dev 2>/dev/null
    umount /tmp/alpine/proc 2>/dev/null
    umount /tmp/alpine/sys 2>/dev/null
    umount /tmp/alpine 2>/dev/null
fi

# 2. Remove temporary runtime directory
if [ -d /tmp/alpine ]; then
    rm -rf /tmp/alpine
    echo "[*] Removed temporary chroot mount directory (/tmp/alpine)."
fi

# 3. Clean up persistent drop-box files from user storage (/mnt/us/)
echo "[*] Removing drop-box files from user storage..."
cd /mnt/us
rm -f alpine.ext3 start-alpine-dropbox.sh setup-dropbox.sh cleanup-dropbox.sh

# 4. Optional: Re-enable standard power-saving / screensaver state
echo "[*] Restoring default power management behavior..."
lipc-set-prop com.lab126.powerd preventScreenSaver 0

echo "[*] Cleanup complete! Your Kindle has been returned to its standard jailbroken state."
