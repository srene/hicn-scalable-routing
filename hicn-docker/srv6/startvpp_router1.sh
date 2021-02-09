#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 1 filename /memif/memif1.sock
create memif socket id 2 filename /memif/memif2.sock
create memif socket id 3 filename /memif/memif3.sock
create interface memif id 0 socket-id 1 slave
create interface memif id 0 socket-id 2 master
create interface memif id 0 socket-id 3 master
set int state memif1/0 up
set int state memif2/0 up
set int state memif3/0 up
set int ip addr memif1/0 fd00::1/64
set int ip addr memif2/0 fd01::1/64
set int ip addr memif3/0 fd02::1/64
ip route add 2::2/128 via fd01::2 memif2/0
ip route add 3::3/128 via fd02::2 memif3/0
set sr encaps source addr 1::1
sr policy add bsid 1::1:999 next 2::2
sr steer l3 b002::1/64 via bsid 1::1:999
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
