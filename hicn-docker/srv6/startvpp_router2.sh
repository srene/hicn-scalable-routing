#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 2 filename /memif/memif2.sock
create memif socket id 4 filename /memif/memif4.sock
create interface memif id 0 socket-id 2 slave
create interface memif id 0 socket-id 4 master
set int state memif2/0 up
set int state memif4/0 up
set int ip addr memif2/0 fd01::2/64
set int ip addr memif4/0 fd03::1/64
ip route add 1::1/128 via fd01::1 memif2/0
ip route add 3::3/128 via fd03::2 memif4/0
ip route add 4::4/128 via fd03::2 memif4/0
ip route add b002::1/64 via fd03::2 memif4/0
sr localsid address 2::2 behavior end.dx6 memif4/0 fd03::2
EOL

sleep 5
# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf 2>&1 > vpp.log

sleep 20	

vppctl hicn enable b002::1/64

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

# We do not want to exit, so ...
tail -f /dev/null
