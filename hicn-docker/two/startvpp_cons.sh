#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 1 filename /memif/memif1.sock
create interface memif id 0 socket-id 1 slave
set int state memif1/0 up
set int ip addr memif1/0 192.168.1.1/24
set int ip addr memif1/0 2001::1/64
ip route add b002::1/64 via 2001::2 memif1/0
EOL

sleep 5
# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf
sleep 20	

vppctl hicn enable b002::1/64

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

sysrepo-plugind -d &
sleep 5
netopeer2-server -d -v 0 &
sleep 5
#vppctl hicn enable b002::1/64
#sleep 2
#hicn-ping-server -n b002::1
# We do not want to exit, so ...
tail -f /dev/null
