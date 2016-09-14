#!/usr/bin/bash
# THIS IS STILL WORK IN PROGRESS

NAME=ironic1

NODE_MAC_ADDR1=00:1E:67:D0:D8:23

NODE_UUID=`ironic node-list | grep ironic1 | awk '{print $2}'`

echo Deleting Ironic Node $NODE_UUID
ironic node-delete $NODE_UUID

NEUTRON_PORT_UUID=`neutron port-list | grep $NODE_MAC_ADDR1 | awk '{print $2}'`

echo Deleting Neutron Port $NEUTRON_PORT_UUID for MAC $NODE_MAC_ADDR1
neutron port-delete $NEUTRON_PORT_UUID
