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
cat > /etc/vpp/config_router1.txt << EOL
create memif socket id 1 filename /run/vpp/memif1.sock
create interface memif id 1 socket-id 1 master
create interface memif id 0 socket-id 0 slave
set interface ip address memif1/1 fd01::1/64 
set int state memif1/1 up
set interface ip address memif0/0 fd00::1/64
set int state memif0/0 up
ip route add b001::0/64 via fd01::2 memif1/1
hicn enable b001::/64
EOL

cat /tmp/startup_init.conf /etc/vpp/startup.conf > /startup.tmp && mv /startup.tmp /etc/vpp/startup.conf

# Run the VPP daemon
/usr/bin/vpp -c /etc/vpp/startup.conf

# Setup the host link
#ip link add name vpp1out type veth peer name vpp1host
#ip link set dev vpp1out up
#ip link set dev vpp1host up
#ip addr add "${HOSTIP}"/"${HOSTMASK}" dev vpp1host
#ip route add "${MEMIFROUTE}"/"${MEMIFMASK}" via "${VPP1HOSTINTIP}"

# Make sure VPP is *really* running
typeset -i cnt=60
until ls -l /run/vpp/cli-vpp_router1.sock ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

#vppctl -s /run/vpp/cli-vpp1.sock create host-interface name vpp1out
#typeset -i cnt=60
#until vppctl -s /run/vpp/cli-vpp1.sock show int | grep vpp1out ; do
#       ((cnt=cnt-1)) || exit 1
#       sleep 1
#       vppctl -s /run/vpp/cli-vpp1.sock create host-interface name vpp1out
#done

#vppctl -s /run/vpp/cli-vpp1.sock set int state host-vpp1out up
#vppctl -s /run/vpp/cli-vpp1.sock set int ip address host-vpp1out "${VPP1HOSTINTIP}"/"${VPP1HOSTINTMASK}"

# We do not want to exit, so ...
tail -f /dev/null
