#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 4 filename /memif/memif4.sock
create memif socket id 5 filename /memif/memif5.sock
create memif socket id 6 filename /memif/memif6.sock
create interface memif id 0 socket-id 4 slave
create interface memif id 0 socket-id 5 slave
create interface memif id 0 socket-id 6 master
set int state memif4/0 up
set int state memif5/0 up
set int state memif6/0 up
set int ip addr memif4/0 fd03::2/64
set int ip addr memif5/0 fd04::2/64
set int ip addr memif6/0 fd05::1/64
ip route add 1::1/128 via fd03::1 memif4/0
ip route add 2::2/128 via fd03::1 memif4/0
ip route add 3::3/128 via fd04::1 memif5/0
ip route add b002::1/128 via fd05::2 memif5/0
EOL

sleep 5
# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf > vpp.log 2>&1 &

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
