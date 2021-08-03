#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 3 filename /memif/memif3.sock
create interface memif id 0 socket-id 3 slave
create memif socket id 4 filename /memif/memif4.sock
create interface memif id 0 socket-id 4 slave
set int state memif3/0 up
set int ip addr memif3/0 fd02::2/64
set int state memif4/0 up
set int ip addr memif4/0 fd03::2/64
ip route add fc00::/64 via fd02::1 memif3/0
EOL

sleep 2

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf > vpp.log 2>&1 &

sleep 10

ip link add name vpp1out type veth peer name vpp1host
ip link set dev vpp1out up
ip link set dev vpp1host up
ip -6 addr add fc01::2/64 dev vpp1host
route add -A inet6 default gw fc01::1

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done


vppctl -s /run/vpp/cli.sock create host-interface name vpp1out
typeset -i cnt=60
until vppctl -s /run/vpp/cli.sock show int | grep vpp1out ; do
       ((cnt=cnt-1)) || return 1
       sleep 1
       vppctl -s /run/vpp/cli.sock create host-interface name vpp1out
done

vppctl -s /run/vpp/cli.sock set int state host-vpp1out up
vppctl -s /run/vpp/cli.sock set int ip address host-vpp1out fc01::1/64
vppctl -s /run/vpp/cli.sock sr localsid address 4::4 behavior end.dx6 host-vpp1out fc01::2
vppctl -s /run/vpp/cli.sock ping fc01::2 repeat 1
# We do not want to exit, so ...
tail -f /dev/null
