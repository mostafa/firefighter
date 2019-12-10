#!/bin/bash

FIRECRACKER_LATEST_RELEASE=$(curl -s https://api.github.com/repos/firecracker-microvm/firecracker/releases/latest \
| grep "firecracker-v" \
| grep "x86_64" \
| grep "browser_download_url" \
| cut -d : -f 2,3 \
| tr -d \")

JAILER_LATEST_RELEASE=$(curl -s https://api.github.com/repos/firecracker-microvm/firecracker/releases/latest \
| grep "jailer-v" \
| grep "x86_64" \
| grep "browser_download_url" \
| cut -d : -f 2,3 \
| tr -d \")

# firecracker + jailer
[[ -e firecracker ]] || curl -Lo firecracker $FIRECRACKER_LATEST_RELEASE
[[ -e jailer ]] || curl -Lo jailer $JAILER_LATEST_RELEASE
chmod +x firecracker
chmod +x jailer

# firectl
[[ -e firectl ]] || curl -Lo firectl https://firectl-release.s3.amazonaws.com/firectl-v0.1.0
chmod +x firectl

[[ -e images ]] || mkdir images && cd images
# alpine
[[ -e alpine.ext4 ]] || curl -fsSL --progress-bar -o alpine.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/minimal/fsfiles/boottime-rootfs.ext4
[[ -e alpine-vmlinuz.bin ]] || curl -fsSL --progress-bar -o alpine-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/minimal/kernel/vmlinux.bin
# debian
[[ -e debian.ext4 ]] || curl -fsSL --progress-bar -o debian.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/fsfiles/debian.rootfs.ext4
[[ -e debian-vmlinuz.bin ]] || curl -fsSL --progress-bar -o debian-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/kernel/vmlinux.bin

cd ..
