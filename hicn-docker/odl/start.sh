#!/bin/bash

/opt/opendaylight/bin/karaf server &
sleep 30
/opt/opendaylight/bin/client -r 7 "feature:install odl-netconf-all odl-restconf-all;"
sleep 30
curl -X POST -H "Content-Type: application/xml, Accept: application/xml" \
     -u admin:admin \
     -d @start.xml \
	http://localhost:8181/restconf/config/network-topology:network-topology/topology/topology-netconf/node/hicn-node

# We do not want to exit, so ...
tail -f /dev/null
