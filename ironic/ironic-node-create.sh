#!/usr/bin/bash

NAME=ironic1
IPMI_ADDR=172.31.2.13
NODE_MAC_ADDR1=00:1E:67:D0:D8:23

#NAME=ironic2
#IPMI_ADDR=172.31.2.14
#NODE_MAC_ADDR1=00:1E:67:D0:D8:2B

DEPLOY_VMLINUZ_UUID=36b98e52-b1ae-4725-94de-71514a9352af
DEPLOY_INITRD_UUID=23011785-a66e-4bb8-9311-888c0f90a95c

CPU=72
RAM_MB=131072
DISK_GB=200
ARCH=x86_64

USER_IMAGE_SOURCE=545811a6-3743-42e2-a6fc-e29d781b2b09
#USER_KERNEL=
#USER_RAMDISK=
USER_ROOT_GB=$DISK_GB

ironic node-create -d pxe_ipmitool -i ipmi_address=$IPMI_ADDR -i ipmi_username=root -i ipmi_password=openhpc -n $NAME

NODE_UUID=`ironic node-list | grep $NAME | awk '{print $2}'`

echo New Ironic Node: $NODE_UUID

ironic node-update $NODE_UUID add driver_info/pxe_deploy_kernel=$DEPLOY_VMLINUZ_UUID driver_info/pxe_deploy_ramdisk=$DEPLOY_INITRD_UUID

ironic node-update $NODE_UUID add driver_info/deploy_kernel=$DEPLOY_VMLINUZ_UUID driver_info/deploy_ramdisk=$DEPLOY_INITRD_UUID

ironic node-update $NODE_UUID add properties/capabilities='boot_mode:bios'

ironic port-create -n $NODE_UUID -a $NODE_MAC_ADDR1

ironic node-update $NODE_UUID add properties/cpus=$CPU properties/memory_mb=$RAM_MB properties/local_gb=$DISK_GB properties/cpu_arch=$ARCH

#ironic node-update $NODE_UUID add instance_info/image_source=$USER_IMAGE_SOURCE instance_info/kernel=$USER_KERNEL instance_info/ramdisk=$USER_RAMDISK instance_info/root_gb=$USER_ROOT_GB
ironic node-update $NODE_UUID add instance_info/image_source=$USER_IMAGE_SOURCE instance_info/root_gb=$USER_ROOT_GB

ironic node-validate $NODE_UUID

