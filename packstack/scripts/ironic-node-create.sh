#!/usr/bin/bash
# THIS IS STILL WORK IN PROGRESS

NAME=ironic1

IPMI_ADDR=172.31.2.13
NODE_MAC_ADDR1=00:1E:67:D0:D8:23

DEPLOY_VMLINUZ_UUID=bca47cc7-9259-48f5-af38-d6aa5d9ddee9
DEPLOY_INITRD_UUID=4f522af9-7437-4808-8579-b1be87758209

CPU=36
RAM_MB=131072
DISK_GB=200
ARCH=x86_64

USER_IMAGE_SOURCE=a691ac5b-2564-4090-a319-42fd9faeef15
USER_KERNEL=913f3ee3-5500-4c25-8831-10599ad11f2b
USER_RAMDISK=719c1863-e248-496e-990b-a8149f7a2eef
USER_ROOT_GB=$DISK_GB

#ironic node-create -d pxe_ipmitool -i ipmi_address=$IPMI_ADDR -i ipmi_username=root -i ipmi_password=openhpc -n $NAME

NODE_UUID=`ironic node-list | grep ironic1 | awk '{print $2}'`

echo New Ironic Node: $NODE_UUID

ironic node-update $NODE_UUID add driver_info/pxe_deploy_kernel=$DEPLOY_VMLINUZ_UUID driver_info/pxe_deploy_ramdisk=$DEPLOY_INITRD_UUID

ironic node-update $NODE_UUID add driver_info/deploy_kernel=$DEPLOY_VMLINUZ_UUID driver_info/deploy_ramdisk=$DEPLOY_INITRD_UUID

ironic node-update $NODE_UUID add properties/capabilities='boot_mode:bios'

ironic port-create -n $NODE_UUID -a $NODE_MAC_ADDR1

ironic node-update $NODE_UUID add properties/cpus=$CPU properties/memory_mb=$RAM_MB properties/local_gb=$DISK_GB properties/cpu_arch=$ARCH

ironic node-update $NODE_UUID add instance_info/image_source=$USER_IMAGE_SOURCE instance_info/kernel=$USER_KERNEL instance_info/ramdisk=$USER_RAMDISK instance_info/root_gb=$USER_ROOT_GB

ironic node-validate $NODE_UUID

