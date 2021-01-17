#!/bin/bash

set -xe

echo "Configure VPP"
if [ -n "$DPDK" ]
then
    BLOCK="dpdk { $DPDK }"
fi

if [ ! -n "$NUM_BUFFER" ]
then
    NUM_BUFFER=16384
fi

if [ ! -n "$PIT_SIZE" ]
then
    PIT_SIZE=131072
fi

if [ ! -n "$CS_SIZE" ]
then
    CS_SIZE=4096
fi

if [ ! -n "$CS_RESERVED_APP" ]
then
    CS_RESERVED_APP=20
fi

eval sed -e "s/DPDK/\"$(echo $BLOCK)\"/g" -e "s/NUM_BUFFER/\"$(echo $NUM_BUFFER)\"/g" -e "s/PIT_SIZE/\"$(echo $PIT_SIZE)\"/g" -e "s/CS_SIZE/\"$(echo $CS_SIZE)\"/g" -e "s/CS_RESERVED_APP/\"$(echo $CS_RESERVED_APP)\"/g" /tmp/startup_template.conf > /etc/vpp/startup.conf

# Generate the config file
cat > /etc/vpp/config2.txt << EOL
create interface memif id 0 slave
set in state memif0/0 up
set int ip address memif0/0 ${VPP2MEMIFIP}/${VPP2MEMIFMASK}
ip route add ${HOSTROUTE}/${HOSTMASK} via ${VPP1MEMIFIP}
EOL

cat /tmp/startup_init.conf /etc/vpp/startup.conf > /startup.tmp && mv /startup.tmp /etc/vpp/startup.conf

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf


# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli-vpp2.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

# We do not want to exit, so ...
tail -f /dev/null
