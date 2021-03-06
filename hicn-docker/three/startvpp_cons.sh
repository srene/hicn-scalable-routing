#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 1 filename /memif/memif1.sock
create interface memif id 0 socket-id 1 master
set int state memif1/0 up
set int ip addr memif1/0 fd00::2/64
ip route add fd01::0/64 table 10 via fd00::1 memif1/0
ip route add b002::1/64 via fd00::1 memif1/0
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

#vppctl hicn enable b002::1/64
#sleep 2
#hicn-ping-server -n b002::1
# We do not want to exit, so ...
tail -f /dev/null
