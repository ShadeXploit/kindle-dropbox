---

```markdown
# Kindle Alpine Tailscale Drop-Box (`kindle-alpine-dropbox`)

Turn a jailbroken Kindle into a persistent, headless, autonomous Tailscale drop-box node running an isolated Alpine Linux chroot environment. 

## Overview

This project allows you to run a lightweight Alpine Linux chroot container directly on a Kindle's user storage (`/mnt/us/`), leveraging Tailscale in userspace-networking mode (`--tun=userspace-networking`) to bypass kernel limitations. By managing power states via `lipc`, the device stays awake, keeps its Wi-Fi radio active, and maintains an un-interrupted connection to your tailnet indefinitely.

## Features

- **Isolated Chroot Environment:** Runs a full Alpine Linux container on top of an `alpine.ext3` virtual disk image.
- **Userspace Networking:** Utilizes Tailscale's userspace networking engine, requiring no kernel tun/tap module modifications.
- **Persistent State:** Retains node authentication and state inside the container image for seamless reconnections.
- **Always-On Power Management:** Overrides Kindle power saving and screensaver timeouts to maintain a continuous Wi-Fi link.
- **Zero Host Mutation:** Avoids messy system modifications; all runtime mounts occur dynamically in `/tmp`.

---

## Repository Structure

```text
├── alpine.ext3               # Base Alpine Linux virtual disk image (place in /mnt/us/)
├── setup-dropbox.sh          # Bootstrap installer script for fresh environments
└── start-alpine-dropbox.sh   # Runtime launcher script (mounts, binds, and starts Tailscale)

```

---

## Prerequisites

* A jailbroken Kindle with KUAL, terminal access (`kterm`), and root SSH enabled.
* Basic familiarity with SSH and command-line file transfers (`sftp` or USB transfer).

---

## Installation & Setup

### Step 1: Transfer Files

Copy your pre-built `alpine.ext3` image, `setup-dropbox.sh`, and `start-alpine-dropbox.sh` into the root of your Kindle's user storage (`/mnt/us/`) via USB or SFTP.

### Step 2: Run the Bootstrap Installer

SSH into your Kindle and execute the setup script to install runtime dependencies (`tailscale`, `bash`, `curl`) inside the chroot:

```bash
sh /mnt/us/setup-dropbox.sh

```

### Step 3: Authenticate Tailscale (First Run Only)

If you haven't baked an existing Tailscale state into your image, run the startup script manually the first time to authenticate against your tailnet:

```bash
sh /mnt/us/start-alpine-dropbox.sh

```

Follow the interactive auth URL provided in the console to authorize your Kindle node on your Tailscale admin console. Once authenticated, the state is permanently saved inside your `alpine.ext3` image.

---

## Usage

To spin up your drop-box node at any time (e.g., after a manual reboot):

1. SSH into your Kindle:
```bash
ssh root@<YOUR_KINDLE_IP>

```


2. Execute the launcher script:
```bash
sh /mnt/us/start-alpine-dropbox.sh

```



The script will automatically mount the virtual filesystem, bind essential devices (`/dev`, `/proc`, `/sys`), start `tailscaled` in the background, bring the interface up, and lock the screen active to prevent your Wi-Fi from dropping.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

```

```
