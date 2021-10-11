#!/bin/bash
VPPCTL=/home/sergi/workspace/vpp/build-root/install-vpp-native/vpp/bin/vppctl
CLISOCK1=/run/vpp/cli1.sock
CLISOCK2=/run/vpp/cli2.sock
CLISOCK3=/run/vpp/cli3.sock


#Config interfaces

typeset -i cnt=60
until ls -l $CLISOCK1 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done


#$VPPCTL -s $CLISOCK1 create memif socket id 0 filename /run/vpp/memif0.sock
$VPPCTL -s $CLISOCK1 create interface memif id 0 socket-id 0 master
sleep 1
$VPPCTL -s $CLISOCK1 set interface ip address memif0/0 2000::1/64
$VPPCTL -s $CLISOCK1 set int state memif0/0 up

$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 0 slave
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif0/0 2000::2/64
$VPPCTL -s $CLISOCK2 set int state memif0/0 up
$VPPCTL -s $CLISOCK2 create memif socket id 1 filename /run/vpp/memif1.sock
sleep 1
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 1 master
$VPPCTL -s $CLISOCK2 set interface ip address memif1/0 2001::1/64
$VPPCTL -s $CLISOCK2 set int state memif1/0 up


$VPPCTL -s $CLISOCK3 create memif socket id 1 filename /run/vpp/memif1.sock
sleep 1
$VPPCTL -s $CLISOCK3 create interface memif id 0 socket-id 1 slave
$VPPCTL -s $CLISOCK3 set interface ip address memif1/0 2001::2/64
$VPPCTL -s $CLISOCK3 set int state memif1/0 up



#Config srv6
#$VPPCTL -s $CLISOCK2 set sr encaps source addr 1::1
#$VPPCTL -s $CLISOCK2 sr policy add bsid 1::1:999 next 2::2 encap
#$VPPCTL -s $CLISOCK2 sr steer l3 b001::/64 via bsid 1::1:999


#$VPPCTL -s $CLISOCK5 sr localsid address 2::2 behavior end.dx6 memif5/0 2005::2

#$VPPCTL -s $CLISOCK6 sr localsid address 3::3 behavior end.dx6 memif6/0 2006::2

#routing
#$VPPCTL -s $CLISOCK2 ip route add 2::2/128 via 2001::2 memif1/0
#$VPPCTL -s $CLISOCK2 ip route add 3::3/128 via 2003::2 memif3/0
#$VPPCTL -s $CLISOCK3 ip route add 2::2/128 via 2002::2 memif2/0
#$VPPCTL -s $CLISOCK4 ip route add 3::3/128 via 2004::2 memif4/0


#hicn config
#$VPPCTL -s $CLISOCK1 hicn pgen client src 5001::2 name b001::1/64 intfc memif0/0
#$VPPCTL -s $CLISOCK1 hicn enable b001::/64
#$VPPCTL -s $CLISOCK1 exec /home/sergi/workspace/hicn-scalable-routing/configs/pg.conf
##$VPPCTL -s $CLISOCK3 hicn enable 2::2/128
#$VPPCTL -s $CLISOCK5 hicn enable 3::3/128
#$VPPCTL -s $CLISOCK3 hicn enable b001::/64
#$VPPCTL -s $CLISOCK7 hicn pgen server name b001::1/64 intfc memif1/0


#tracing 
$VPPCTL -s $CLISOCK1 trace add memif-input 50
$VPPCTL -s $CLISOCK2 trace add af-packet-input 50
$VPPCTL -s $CLISOCK2 trace add memif-input 50
$VPPCTL -s $CLISOCK3 trace add memif-input 50
#$VPPCTL -s $CLISOCK4 trace add memif-input 50
#$VPPCTL -s $CLISOCK5 trace add memif-input 50
#$VPPCTL -s $CLISOCK6 trace add memif-input 50
#$VPPCTL -s $CLISOCK7 trace add memif-input 50


