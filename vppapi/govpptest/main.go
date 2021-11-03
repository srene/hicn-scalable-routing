package main

import (
        "fmt"
        "git.fd.io/govpp.git"
        "git.fd.io/govpp.git/binapi/interface"
        "git.fd.io/govpp.git/binapi/tracedump"
        "git.fd.io/govpp.git/binapi/vpe"
        "git.fd.io/govpp.git/binapi/sr"
        "git.fd.io/govpp.git/binapi/ip_types"
        "git.fd.io/govpp.git/api"
        "git.fd.io/govpp.git/binapi/interface_types"
        "time"
        "os"
        "encoding/json"

)

var errors []error

func addIPAddress(addr string, ch api.Channel, index interface_types.InterfaceIndex) {
        ipAddr, err := ip_types.ParsePrefix(addr)
        if err != nil {
                fmt.Printf("ERROR: %v\n", err)
                return
        }

        req := &interfaces.SwInterfaceAddDelAddress{
                SwIfIndex: index,
                IsAdd:     true,
                Prefix:    ip_types.AddressWithPrefix(ipAddr),
        }
        reply := &interfaces.SwInterfaceAddDelAddressReply{}

        if err := ch.SendRequest(req).ReceiveReply(reply); err != nil {
                fmt.Printf("ERROR: %v\n", err)
                return
        }
        fmt.Printf(" - IP address %s added to interface with index %d\n", addr, index)
}

func marshal(v interface{}) {
    fmt.Printf("GO: %#v\n", v)
    b, err := json.MarshalIndent(v, "", "  ")
    if err != nil {
        panic(err)
    }
    fmt.Printf("JSON: %s\n", b)
}

func logError(err error, msg string) {
    fmt.Printf("ERROR: %s: %v\n", msg, err)
    errors = append(errors, err)
}

// interfaceNotifications shows the usage of notification API. Note that for notifications,
// you are supposed to create your own Go channel with your preferred buffer size. If the channel's
// buffer is full, the notifications will not be delivered into it.
func interfaceNotifications(ch api.Channel, index interface_types.InterfaceIndex) {
    fmt.Printf("Subscribing to notificaiton events for interface index %d\n", index)

    notifChan := make(chan api.Message, 100)

    // subscribe for specific notification message
    sub, err := ch.SubscribeNotification(notifChan, &interfaces.SwInterfaceEvent{})
    if err != nil {
        logError(err, "subscribing to interface events")
        return
    }

    // enable interface events in VPP
    err = ch.SendRequest(&interfaces.WantInterfaceEvents{
        PID:           uint32(os.Getpid()),
        EnableDisable: 1,
    }).ReceiveReply(&interfaces.WantInterfaceEventsReply{})
    if err != nil {
        logError(err, "enabling interface events")
        return
    }

    // receive notifications
    go func() {
        for notif := range notifChan {
            e := notif.(*interfaces.SwInterfaceEvent)
            fmt.Printf("incoming event: %+v\n", e)
            marshal(e)
        }
    }()

    // generate some events in VPP
    err = ch.SendRequest(&interfaces.SwInterfaceSetFlags{
        SwIfIndex: index,
        Flags:     interface_types.IF_STATUS_API_FLAG_ADMIN_UP,
    }).ReceiveReply(&interfaces.SwInterfaceSetFlagsReply{})
    if err != nil {
        logError(err, "setting interface flags")
        return
    }
    err = ch.SendRequest(&interfaces.SwInterfaceSetFlags{
        SwIfIndex: index,
        Flags:     0,
    }).ReceiveReply(&interfaces.SwInterfaceSetFlagsReply{})
    if err != nil {
        logError(err, "setting interface flags")
        return
    }

    // disable interface events in VPP
    err = ch.SendRequest(&interfaces.WantInterfaceEvents{
        PID:           uint32(os.Getpid()),
        EnableDisable: 0,
    }).ReceiveReply(&interfaces.WantInterfaceEventsReply{})
    if err != nil {
        logError(err, "setting interface flags")
        return
    }

    // unsubscribe from delivery of the notifications
    err = sub.Unsubscribe()
    if err != nil {
        logError(err, "unsubscribing from interface events")
        return
    }

    fmt.Println("OK")
    fmt.Println()
}

func main() {
        // Connect to VPP
        conn, _ := govpp.Connect("/run/vpp/api2.sock")
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

        addIPAddress("10.10.0.1/24", ch, loop_create_reply.SwIfIndex)

        fmt.Printf("create_loopback: sw_if_index %d\n",
                int(loop_create_reply.SwIfIndex))

        ip_encap,_:= ip_types.ParseIP6Address("1::1")
        sr_encap := &sr.SrSetEncapSource{
                        EncapsSource: ip_encap,
                }
        sr_encap_reply := &sr.SrSetEncapSourceReply{}
        err = ch.SendRequest(sr_encap).ReceiveReply(sr_encap_reply)

        if err != nil {
                fmt.Errorf("create_encap: %w\n", err)
        }

        fmt.Printf("create_encap: ret val %d\n",
                int(sr_encap_reply.Retval))

                    time.Sleep(2 * time.Second)
      ip,_:= ip_types.ParseIP6Address("1::1:999")
      ip_sid,_:= ip_types.ParseIP6Address("2::2")
      sids :=[16]ip_types.IP6Address{ip_sid}
      sr_create := &sr.SrPolicyAdd{BsidAddr: ip,
                IsEncap: true,
                Sids: sr.Srv6SidList{NumSids:1,Sids: sids},
      }
        /*sr_create := &sr.SrPolicyAdd{
                        BsidAddr: ip,
//                              Weight:   1,
                                IsEncap:  true,
//                              IsSpray:  false,
                              FibTable: 1,
//                              Sids:     sr.Srv6SidList{Weight: 1},
        }*/
        sr_create_reply := &sr.SrPolicyAddReply{}

        err = ch.SendRequest(sr_create).ReceiveReply(sr_create_reply)

        if err != nil {
                fmt.Errorf("create_policy: %w\n", err)
        }

        fmt.Printf("create_policy: ret val %d\n",
                int(sr_create_reply.Retval))

        ip_steering,_:=ip_types.ParsePrefix("b001::/64")        
        sr_steering := &sr.SrSteeringAddDel{IsDel: false,
                                BsidAddr: ip,
                                Prefix: ip_steering,
                                TrafficType: 6}
        sr_steering_reply := &sr.SrSteeringAddDelReply{}
        err = ch.SendRequest(sr_steering).ReceiveReply(sr_steering_reply)

        if err!= nil {
                fmt.Errorf("create_steering %w\n", err)
        }

        fmt.Printf("create steering: ret val %d\n",
                int(sr_steering_reply.Retval))


        // process errors encountered during the example
        defer func() {
            if len(errors) > 0 {
                fmt.Printf("finished with %d errors\n", len(errors))
                os.Exit(1)
            } else {
                fmt.Println("finished successfully")
            }
        }()

        //interfaceNotifications(ch, loop_create_reply.SwIfIndex)

        trace_create := &tracedump.TraceCapturePackets{}
        trace_reply := &tracedump.TraceCapturePacketsReply{}

         err = ch.SendRequest(trace_create).ReceiveReply(trace_reply)

        if err!= nil {
            fmt.Errorf("error tracing %w\n", err)
        }

        fmt.Printf("create tracing: ret val %d\n",
            int(trace_reply.Retval))


}




