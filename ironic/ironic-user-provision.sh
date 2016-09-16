#!/usr/bin/bash

# CHANGE THESE VARIABLES
NAME=bm1
FLAVOR=my-baremetal-flavor
KEYPAIR=ironic-key
GUEST_IMAGE=ironic-user-ubuntu
NETWORK_ID=4d5fd01c-4be6-4de2-b24e-68df725b809b

# Use nova to boot up the ironic node with the flavor, keypair, guest OS image and the attached network
nova boot --flavor $FLAVOR --key-name $KEYPAIR --image $GUEST_IMAGE --nic net-id=$NETWORK_ID $NAME

# List nova instances
nova list 

# List ironic nodes
ironic node-list

