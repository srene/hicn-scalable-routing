package main

import (
	"fmt"
	"git.fd.io/govpp.git"
	"git.fd.io/govpp.git/binapi/interface"
	"git.fd.io/govpp.git/binapi/vpe"
)

func main() {
	// Connect to VPP
	conn, _ := govpp.Connect("/run/vpp/api.sock")
	defer conn.Disconnect()

	// Open channel
	ch, _ := conn.NewAPIChannel()
	defer ch.Close()

	// Prepare messages
	req := &vpe.ShowVersion{}
	reply := &vpe.ShowVersionReply{}

	// Send the request
	err := ch.SendRequest(req).ReceiveReply(reply)

	if err != nil {
		fmt.Errorf("SendRequest: %w\n", err)
	}

	fmt.Printf("Program: %s\nVersion: %s\nBuildDate: %s\n",
		reply.Program, reply.Version, reply.BuildDate)

	loop_create := &interfaces.CreateLoopback{}
	loop_create_reply := &interfaces.CreateLoopbackReply{}

	err = ch.SendRequest(loop_create).ReceiveReply(loop_create_reply)

	if err != nil {
		fmt.Errorf("create_loopback: %w\n", err)
	}

	fmt.Printf("create_loopback: sw_if_index %d",
		int(loop_create_reply.SwIfIndex))
}
