#!/bin/bash

script=$(basename $0)

command_usage () {
	echo "Usage:"
	echo "${script} start <distro-name> | <vmlinuz.bin> <rootfs.ext4>"
	echo "${script} stop"
	echo "${script} config"
	echo "${script} status"
	echo
	echo "Available distros:"
	echo " - debian"
	echo " - alpine"
}

_start () {
	# command parameters
	kernel=$1
	rootfs=$2

	echo "Giving read/write access to KVM to ${USER}"
	sudo setfacl -m u:${USER}:rw /dev/kvm

	if [ -z $1 ]
	then
		command_usage
		exit -1
	elif [ -n $1 ] && [ -z $2 ]
	then
		case $1 in
			debian)
				kernel=images/debian-vmlinuz.bin
				rootfs=images/debian.ext4
				;;
			alpine)
				kernel=images/alpine-vmlinuz.bin
				rootfs=images/alpine.ext4
				;;
			*)
		esac
	fi

	echo "Booting kernel: $kernel"
	echo "Image: $rootfs"
	if [ -r /dev/kvm ] && [ -w /dev/kvm ]
	then
		echo "Create TAP device"
		sudo ip tuntap add tap0 mode tap
		
		echo "Save MAC address of the TAP device"
		tap0_address=`cat /sys/class/net/tap0/address`
		echo "TAP MAC address: $tap0_address"
		
		echo "Set IP address on TAP device and set mode to UP"
		sudo ip addr add 172.16.0.1/24 dev tap0
		sudo ip link set tap0 up

		echo "Save IP forwarding and enable it"
		sudo cat /proc/sys/net/ipv4/ip_forward > ./.ip_forward.old
		sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

		echo "Find default network interface with internet access"
		inet_iface=$(sudo ip route | grep default | awk '{print $5}')
		echo "Internet-facing interface: $inet_iface"

		echo "Enable routing from/to MicroVM"
		sudo iptables -t nat -A POSTROUTING -o $inet_iface -j MASQUERADE
		sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
		sudo iptables -A FORWARD -i tap0 -o $inet_iface -j ACCEPT

		echo "Run MicroVM"
		sudo ./firectl \
				--firecracker-binary=./firecracker \
				--kernel=$kernel \
				--root-drive=$rootfs \
				--cpu-template=T2 \
				--firecracker-log=./.firecracker-vmm.log \
				--kernel-opts="console=ttyS0 noapic reboot=k panic=1 pci=off nomodules ro" \
				-c 2 \
				-m 512 \
				--tap-device=tap0/$tap0_address \
				--socket-path=./firecracker.socket
	fi
}

_stop () {
	echo "Kill firecracker"
	sudo killall firecracker >/dev/null 2>&1
	
	echo "Stop and remove TAP device"
	sudo ip link set tap0 down >/dev/null 2>&1
	sudo ip link del tap0 >/dev/null 2>&1

	echo "Find default network interface with internet access"
	inet_iface=$(sudo ip route | grep default | awk '{print $5}')
	echo "Internet-facing interface: $inet_iface"

	echo "Disable routing from/to MicroVM"
	sudo iptables -t nat -D POSTROUTING -o $inet_iface -j MASQUERADE
	sudo iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -D FORWARD -i tap0 -o $inet_iface -j ACCEPT
	if [ -f ./.iptables.rules.old ]; then
		sudo iptables-restore < ./.iptables.rules.old
	fi
}

_status () {
	echo "Status:"
	sudo curl --unix-socket firecracker.socket http://localhost/
}

_config () {
	echo "Machine config:"
	sudo curl --unix-socket firecracker.socket http://localhost/machine-config
}

if [ -z $1 ]
then
	command_usage
	exit -1
elif [ -n $1 ]
then
	case $1 in
		start)
			_start $2 $3
			;;
		stop)
			_stop
			;;
		config)
			_config
			;;
		status)
			_status
			;;		
		*)
	esac
fi
