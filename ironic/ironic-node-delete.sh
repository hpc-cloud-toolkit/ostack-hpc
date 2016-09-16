#!/usr/bin/bash

# CHANGE THESE VARIABLES
NAME=ironic1
NODE_MAC_ADDR1=00:1E:67:D0:D8:2B

# Retrieve the uuid of ironic node with the given name
NODE_UUID=`ironic node-list | grep $NAME | awk '{print $2}'`

#set node to maintenance and manage in case of failure
#ironic node-set-maintenance $NODE_UUID true
#ironic node-set-provision-state $NODE_UUID manage

# Delete the specific ironic node 
echo Deleting Ironic Node $NODE_UUID
ironic node-delete $NODE_UUID

# In the event of failure, the neutron port-list might not be cleaned-up properly.
# The next provisioning will fail if you try to enroll the same node with the same mac address 
NEUTRON_PORT_UUID=`neutron port-list | grep -i $NODE_MAC_ADDR1 | awk '{print $2}'`
echo Deleting Neutron Port $NEUTRON_PORT_UUID for MAC $NODE_MAC_ADDR1
neutron port-delete $NEUTRON_PORT_UUID
