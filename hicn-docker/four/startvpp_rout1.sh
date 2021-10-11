#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 1 filename /memif/memif1.sock
create memif socket id 3 filename /memif/memif3.sock
create interface memif id 0 socket-id 1 slave
create interface memif id 0 socket-id 3 master
set int state memif1/0 up
set int state memif3/0 up
set int ip addr memif1/0 fd00::2/64
set int ip addr memif3/0 fd02::1/64
ip route add b002::1/64 via fd02::2 memif3/0
EOL

sleep 5
# Run the VPP daemon
vpp -c /etc/vpp/startup.conf
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
