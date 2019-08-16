#!/bin/bash

# firecracker + jailer
[[ -e firecracker ]] || curl -Lo firecracker https://github.com/firecracker-microvm/firecracker/releases/download/v0.17.0/firecracker-v0.17.0
[[ -e jailer ]] || curl -Lo jailer https://github.com/firecracker-microvm/firecracker/releases/download/v0.17.0/jailer-v0.17.0
chmod +x firecracker
chmod +x jailer

# firectl
[[ -e firectl ]] || curl -Lo firectl https://firectl-release.s3.amazonaws.com/firectl-v0.1.0
chmod +x firectl

[[ -e images ]] || mkdir images && cd images
# alpine
[[ -e alpine.ext4 ]] || curl -fsSL -o alpine.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/minimal/fsfiles/boottime-rootfs.ext4
[[ -e alpine-vmlinuz.bin ]] || curl -fsSL -o alpine-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/minimal/kernel/vmlinux.bin
# debian
[[ -e debian.ext4 ]] || curl -fsSL -o debian.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/fsfiles/debian.rootfs.ext4
[[ -e debian-vmlinuz.bin ]] || curl -fsSL -o debian-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/kernel/vmlinux.bin

cd ..
