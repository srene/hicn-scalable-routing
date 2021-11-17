#!/bin/bash
VPP=/home/sergi/workspace/vpp/build-root/install-vpp-native/vpp/bin/vpp
gnome-terminal --title="Router 1 - Client" -- tmuxinator start vpp1 
gnome-terminal --title="Router 2 - Path 1 " -- tmuxinator start vpp2
gnome-terminal --title="Router 3 - Path 2 " -- tmuxinator start vpp3
gnome-terminal --title="Router 4 - Server " -- tmuxinator start vpp4

$VPP -c startup2.conf &
$VPP -c startup5.conf &

gnome-terminal --title="hICN controller " -- tmuxinator start controller

sleep 2
sudo ./config.sh
