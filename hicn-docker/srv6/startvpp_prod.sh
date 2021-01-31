#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 3 filename /memif/memif3.sock
create memif socket id 4 filename /memif/memif4.sock
create interface memif id 0 socket-id 3 master
create interface memif id 0 socket-id 4 master
set int state memif3/0 up
set int ip addr memif3/0 fd02::2/64
set int state memif4/0 up
set int ip addr memif4/0 fd03::2/64
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

hicn-ping-server -n b002::1

# We do not want to exit, so ...
tail -f /dev/null
