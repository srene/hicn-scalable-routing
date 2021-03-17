#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 1 filename /memif/memif1.sock
create interface memif id 0 socket-id 1 master
create memif socket id 2 filename /memif/memif2.sock
create interface memif id 0 socket-id 2 master
set int state memif1/0 up
set int ip addr memif1/0 fd00::1/64
set int state memif2/0 up
set int ip addr memif2/0 fd01::1/64
set sr encaps source addr 1::1
sr policy add bsid 1::1:999 next 2::2 next 4::4 encap
sr steer l3 fc01::/64 via bsid 1::1:999
ip route add 2::2/128 via fd00::2 memif1/0
ip route add 3::3/128 via fd01::2 memif2/0
EOL

sleep 5
# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf > vpp.log 2>&1 &
sleep 20	

#vppctl hicn enable b002::1/64
ip link add name vpp1out type veth peer name vpp1host
ip link set dev vpp1out up
ip link set dev vpp1host up
ip -6 addr add fc00::2/64 dev vpp1host
route add -A inet6 default gw fc00::1

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
vppctl -s /run/vpp/cli.sock set int ip address host-vpp1out fc00::1/64


# We do not want to exit, so ...
tail -f /dev/null
