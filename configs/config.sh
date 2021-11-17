#!/bin/bash
VPPCTL=/home/sergi/workspace/vpp/build-root/install-vpp-native/vpp/bin/vppctl
CLISOCK1=/run/vpp/cli1.sock
CLISOCK2=/run/vpp/cli2.sock
CLISOCK3=/run/vpp/cli3.sock
CLISOCK4=/run/vpp/cli4.sock
CLISOCK5=/run/vpp/cli5.sock
CLISOCK6=/run/vpp/cli6.sock


#Config interfaces

typeset -i cnt=60
until ls -l $CLISOCK1 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

typeset -i cnt=60
until ls -l $CLISOCK2 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

typeset -i cnt=60
until ls -l $CLISOCK3 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

typeset -i cnt=60
until ls -l $CLISOCK4 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

typeset -i cnt=60
until ls -l $CLISOCK5 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

typeset -i cnt=60
until ls -l $CLISOCK6 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done



#$VPPCTL -s $CLISOCK1 create memif socket id 0 filename /run/vpp/memif0.sock
$VPPCTL -s $CLISOCK1 create interface memif id 0 socket-id 0 master
sleep 1
$VPPCTL -s $CLISOCK1 set interface ip address memif0/0 2000::1/64
sleep 1
$VPPCTL -s $CLISOCK1 set int state memif0/0 up
sleep 1
iface=$($VPPCTL -s $CLISOCK1 create loopback interface)
sleep 1
echo $iface
$VPPCTL -s $CLISOCK1 set interface state $iface up
sleep 1
$VPPCTL -s $CLISOCK1 set interface ip address $iface 5002::1/64
sleep 1
$VPPCTL -s $CLISOCK1 ip neighbor $iface 5002::2 de:ad:00:00:00:00

sleep 1
#$VPPCTL -s $CLISOCK2 create memif socket id 0 filename /run/vpp/memif0.sock
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 0 slave
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif0/0 2000::2/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif0/0 up
sleep 1
$VPPCTL -s $CLISOCK2 create memif socket id 1 filename /run/vpp/memif1.sock
sleep 1
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 1 master
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif1/0 2001::1/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif1/0 up
sleep 1
$VPPCTL -s $CLISOCK2 create memif socket id 3 filename /run/vpp/memif3.sock
sleep 1
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 3 master
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif3/0 2003::1/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif3/0 up

sleep 1
$VPPCTL -s $CLISOCK3 create memif socket id 1 filename /run/vpp/memif1.sock
sleep 1
$VPPCTL -s $CLISOCK3 create interface memif id 0 socket-id 1 slave
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address memif1/0 2001::2/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state memif1/0 up
sleep 1
$VPPCTL -s $CLISOCK3 create memif socket id 2 filename /run/vpp/memif2.sock
sleep 1
$VPPCTL -s $CLISOCK3 create interface memif id 0 socket-id 2 master
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address memif2/0 2002::1/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state memif2/0 up

sleep 1
$VPPCTL -s $CLISOCK4 create memif socket id 3 filename /run/vpp/memif3.sock
sleep 1
$VPPCTL -s $CLISOCK4 create interface memif id 0 socket-id 3 slave
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address memif3/0 2003::2/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state memif3/0 up
sleep 1
$VPPCTL -s $CLISOCK4 create memif socket id 4 filename /run/vpp/memif4.sock
sleep 1
$VPPCTL -s $CLISOCK4 create interface memif id 0 socket-id 4 master
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address memif4/0 2004::1/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state memif4/0 up

sleep 1
$VPPCTL -s $CLISOCK5 create memif socket id 2 filename /run/vpp/memif2.sock
sleep 1
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 2 slave
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif2/0 2002::2/64
$VPPCTL -s $CLISOCK5 set int state memif2/0 up
sleep 1
$VPPCTL -s $CLISOCK5 create memif socket id 4 filename /run/vpp/memif4.sock
sleep 1
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 4 slave
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif4/0 2004::2/64
$VPPCTL -s $CLISOCK5 set int state memif4/0 up
sleep 1
$VPPCTL -s $CLISOCK5 create memif socket id 5 filename /run/vpp/memif5.sock
sleep 1
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 5 master
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif5/0 2005::1/64
sleep 1
$VPPCTL -s $CLISOCK5 set int state memif5/0 up

sleep 1
$VPPCTL -s $CLISOCK6 create memif socket id 5 filename /run/vpp/memif5.sock
sleep 1
$VPPCTL -s $CLISOCK6 create interface memif id 0 socket-id 5 slave
sleep 1
$VPPCTL -s $CLISOCK6 set interface ip address memif5/0 2005::2/64
sleep 1
$VPPCTL -s $CLISOCK6 set int state memif5/0 up


#routing
$VPPCTL -s $CLISOCK2 ip route add 2::2/128 via 2001::2 memif1/0
#sleep 1
$VPPCTL -s $CLISOCK2 ip route add 3::3/128 via 2003::2 memif3/0
#sleep 1
$VPPCTL -s $CLISOCK3 ip route add 2::2/128 via 2002::2 memif2/0
#sleep 1
$VPPCTL -s $CLISOCK4 ip route add 3::3/128 via 2004::2 memif4/0
#sleep 1
$VPPCTL -s $CLISOCK1 ip route add b001::/64 via 2000::2 memif0/0
#sleep 1
$VPPCTL -s $CLISOCK6 ip route add 2002::/64 table 10 via 2005::1 memif5/0
#sleep 1
$VPPCTL -s $CLISOCK6 ip route add 2004::/64 table 10 via 2005::1 memif5/0
#sleep 1
$VPPCTL -s $CLISOCK3 ip route add 2000::/64 table 10 via 2001::1 memif1/0
#sleep 1
$VPPCTL -s $CLISOCK4 ip route add 2000::/64 table 10 via 2003::1 memif3/0

#Config srv6
#$VPPCTL -s $CLISOCK2 set sr encaps source addr 1::1
#sleep 1
#$VPPCTL -s $CLISOCK2 sr policy add bsid 1::1:999 next 3::3 encap
#sleep 1
#$VPPCTL -s $CLISOCK2 sr steer l3 b001::/64 via bsid 1::1:999

sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 2::2 behavior end.dx6 memif5/0 2005::2
sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 3::3 behavior end.dx6 memif5/0 2005::2


#hicn config
$VPPCTL -s $CLISOCK1 hicn pgen client src 5001::2 name b001::1/64 intfc memif0/0
sleep 1
$VPPCTL -s $CLISOCK1 hicn enable b001::/64
sleep 1
$VPPCTL -s $CLISOCK1 exec /home/sergi/workspace/hicn-scalable-routing/configs/pg.conf
#sleep 1
$VPPCTL -s $CLISOCK3 hicn enable 2::2/128
#sleep 1
$VPPCTL -s $CLISOCK4 hicn enable 3::3/128
#sleep 1
$VPPCTL -s $CLISOCK6 hicn pgen server name b001::1/64 intfc memif5/0


#tracing 
$VPPCTL -s $CLISOCK1 trace add memif-input 50
$VPPCTL -s $CLISOCK2 trace add memif-input 50
$VPPCTL -s $CLISOCK3 trace add memif-input 50
$VPPCTL -s $CLISOCK4 trace add memif-input 50
$VPPCTL -s $CLISOCK5 trace add memif-input 50
$VPPCTL -s $CLISOCK6 trace add memif-input 50

