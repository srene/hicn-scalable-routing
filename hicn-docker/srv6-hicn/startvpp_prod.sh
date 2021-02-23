#!/bin/bash

cat > /etc/vpp/config.txt << EOL
create memif socket id 6 filename /memif/memif6.sock
create interface memif id 0 socket-id 6 slave
set int state memif6/0 up
set int ip addr memif6/0 fd05::2/64
EOL

sleep 2

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf > vpp.log 2>&1 &

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
