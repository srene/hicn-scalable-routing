#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 6 filename /memif/memif6.sock
create interface memif id 0 socket-id 6 slave
set int state memif6/0 up
set int ip addr memif6/0 fd05::2/64
EOL

sleep 2

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf > vpp.log 2>&1 &

sleep 10

ip link add name vpp1out type veth peer name vpp1host
ip link set dev vpp1out up
ip link set dev vpp1host up
ip -6 addr add b002::1/64 dev vpp1host
ip -6 route add fc00::/64 via b002::2

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done


vppctl -s /run/vpp/cli-vpp.sock create host-interface name vpp1out
typeset -i cnt=60
until vppctl -s /run/vpp/cli-vpp.sock show int | grep vpp1out ; do
       ((cnt=cnt-1)) || return 1
       sleep 1
       vppctl -s /run/vpp/cli-vpp.sock create host-interface name vpp1out
done

vppctl -s /run/vpp/cli-vpp.sock set int state host-vpp1out up
vppctl -s /run/vpp/cli-vpp.sock set int ip address host-vpp1out b002::2/64

# We do not want to exit, so ...
tail -f /dev/null
