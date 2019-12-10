# Firefighter

Firefighter is, for now, as set of scripts to download or build from source the [firecracker](https://github.com/firecracker-microvm/firecracker) and the [firectl](https://github.com/firecracker-microvm/firectl), download linux images and then eventually run them as a microvm.

For now, things are opinionated. But I'll fix it in the future and make everything configurable.

For starting a new microvm, run this:

```bash
git clone https://gitlab.com/moradian/firefighter
cd firefighter
./run_microvm.sh start alpine
```

You'll eventually be in a shell inside alpine. To enable networking and internet connectivity, run this:

The username and password is `root`.

```bash
ip addr add 172.16.0.2/24 dev eth0
ip route add default via 172.16.0.1 dev eth0
echo "nameserver 8.8.8.8" > /etc/resolv.conf
ping google.com
```

To stop the microvm, run `restart` inside microvm and then `./run_microvm.sh stop` from your host.
