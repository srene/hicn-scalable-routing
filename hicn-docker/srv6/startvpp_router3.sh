#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 3 filename /memif/memif3.sock
create memif socket id 5 filename /memif/memif5.sock
create interface memif id 0 socket-id 3 slave
create interface memif id 0 socket-id 5 master
set int state memif3/0 up
set int state memif5/0 up
set int ip addr memif3/0 fd02::2/64
set int ip addr memif5/0 fd04::1/64
ip route add 1::1/128 via fd02::1 memif3/0
ip route add 2::2/128 via fd04::2 memif5/0
ip route add 4::4/128 via fd04::2 memif5/0
ip route add b002::1/64 via fd04::2 memif5/0
sr localsid address 3::3 behavior end.dx6 memif5/0 fd04::2
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
