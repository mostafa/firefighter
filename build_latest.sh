#!/bin/bash

mkdir sources
cd sources
git clone https://github.com/firecracker-microvm/firecracker
cd firecracker
tools/devtool build -l musl --release
cp build/release-musl/* ../../

cd ..
git clone https://github.com/firecracker-microvm/firectl
cd firectl
make
cp firectl ../../

cd ../../
mkdir images
cd images

curl -fsSL -o alpine.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/minimal/fsfiles/boottime-rootfs.ext4
curl -fsSL -o alpine-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/minimal/kernel/vmlinux.bin

curl -fsSL -o debian.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/fsfiles/debian.rootfs.ext4
curl -fsSL -o debian-vmlinuz.bin https://s3.amazonaws.com/spec.ccfc.min/img/x86_64/debian_with_ssh_and_balloon/kernel/vmlinux.bin

cd ..
