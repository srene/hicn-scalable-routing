#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 2 filename /memif/memif2.sock
create interface memif id 0 socket-id 2 master
set int state memif2/0 up
#set int ip addr memif2/0 192.168.1.2/24
set int ip addr memif2/0 fd01::1/64
ip route add fd00:0/64 table via fd01::1 memif2/0
#set nsim delay 20 ms bandwidth 0.1 gbit packet-size 128
#nsim output-feature enable-disable memif1/0 
EOL

sleep 2

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf

sleep 10

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done
#vppctl hicn enable b002::1/64
#sleep 2
hicn-ping-server -n b002::1
# We do not want to exit, so ...
tail -f /dev/null
