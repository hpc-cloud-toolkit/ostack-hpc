#!/bin/bash
#---------------------------------------------------------------------------------
#This script installs and configures ironic for baremetal provisioning on CentOS 7
#Using the OpenStack-Mitaka release
#This relies on the packstack installation to happen first.
#---------------------------------------------------------------------------------

#Create the endpoint for the Bare metal service's API node
openstack endpoint create --region RegionOne --publicurl http://<sms_ip>:6385 --internalurl http://<sms_ip>:6385 --adminurl http://<sms_ip>:6385 baremetal

#Create roles for the baremetal service. These can be used later to give special permissions to baremetal. This script will be using the defaults.
openstack role create baremetal_admin
openstack role create baremetal_observer

#Restart the ironic-api service
systemctl restart openstack-ironic-api

#Ensure the utilities for baremetal are installed
yum install -y qemu-img iscsi-initiator-utils

#Make the directory for tftp and give it the ironic owner
mkdir -p /tftpboot
chown -R ironic /tftpboot

#Install the packages for PXE boot
yum install -y tftp-server syslinux-tftpboot xinetd

#Copy our template configuration for xinetd into /etc/xinet.d/tftp
mv /etc/xinet.d/tftp /etc/xinet.d/tftp.bak
cp tftp /etc/xinet.d/

#Restart the xinetd service
systemctl restart xinetd

#Copy the PXE linux files to the tftpboot directory we created
cp /var/lib/tftpboot/pxelinux.0 /tftpboot
cp /var/lib/tftpboot/chain.c32 /tftpboot

#Generate a map file for the PXE files
echo 're ^(/tftpboot/) /tftpboot/\2' > /tftpboot/map-file
echo 're ^/tftpboot/ /tftpboot/' >> /tftpboot/map-file
echo 're ^(^/) /tftpboot/\1' >> /tftpboot/map-file
echo 're ^([^/]) /tftpboot/\1' >> /tftpboot/map-file

#Edit our template ironic.conf file with the <sms_ip> variable's value
sed --in-place "s|sms_ip|${sms_ip}|" ironic.conf

#Copy the ironic.conf file into /etc/ironic/ironic.conf
mv /etc/ironic/ironic.conf /etc/ironic/ironic.conf.old
cp ironic.conf /etc/ironic/ironic.conf

#Restart ironic, nova, and ovs to load in the new configuration
systemctl restart openstack-ironic-conductor
systemctl restart openstack-nova-scheduler
systemctl restart openstack-nova-compute
systemctl restart neutron-openvswitch-agent

#Source the keystonerc_admin file
source ${HOME}/keystonerc_admin

#Get the tenant ID for the services tenant
SERVICES_TENANT_ID=`keystone tenant-list | grep services | awk '{print $2}'`

#Create the flat network on which you are going to launch instances
neutron net-create --tenant-id ${SERVICES_TENANT_ID} sharednet1 --shared --provider:network_type flat --provider:physical_network physnet1

#Create the subnet on the newly created network
neutron subnet-create sharednet1 ${NETWORK_CIDR} --name ${SUBNET_NAME} --ip-version=4 --gateway=$GATEWAY_IP --allocation-pool start=${START_IP},end=${END_IP} --enable-dhcp

#Edit the ironic.conf file and input the newly created neutron network into the cleaning_network_uuid configuration
NEUTRON_NETWORK_UUID=`neutron net-list | grep sharednet1 | awk '{print $2}'`
sed --in-place "s|neutron_network_uuid|${NEUTRON_NETWORK_UUID}|" /etc/ironic/ironic.conf

#Restart the ironic-conductor service
systemctl restart openstack-ironic-conductor

#Create the whole-disk-image from the qcow2 file
glance image-create --name whole-disk-image --visibility public --disk-format qcow2 --container-format bare < my-cent7-hpc2.qcow2
WHOLE_DISK_IMAGE_UUID=`lgance image-list | grep whole-disk-image | awk '{print $2}'`

#Create the deploy-kernel and deploy-initrd images
glance image-create --name deploy-vmlinuz --visibility public --disk-format aki --container-format aki < ironic-deploy-c7.vmlinuz
glance image-create --name deploy-initrd --visibility public --disk-format ari --container-format ari < ironic-deploy-c7.initramfs
DEPLOY_VMLINUZ_UUID=`glance image-list | grep deploy-vmlinuz | awk '{print $2}'`
DEPLOY_INITRD_UUID=`glance image-list | grep deploy-initrd | awk '{print $2}'`

#Create the baremetal flavor and set the architecture to x86_64
nova flavor-create baremetal-flavor baremetal-flavor $(((${RAM_MB}-512))) ${DISK_GB} ${CPU}
nova flavor-key baremetal-flavor set cpu_arch=$ARCH
nova flavor-key baremetal-flavor set capabilities:boot_option="bios"

#Create a node in the bare metal service
ironic node-create -d pxe_ipmitool -i deploy_kernel=${DEPLOY_VMLINUZ_UUID} -i deploy_ramdisk=${DEPLOY_INITRD_UUID} -i ipmi_terminal_port=8023 -i ipmi_address=${cc_bmc[0]} -i ipmi_username=root -i ipmi_password=openstack -p cpus=${CPU} -p memory_mb=$(((${RAM_MB}-512))) -p local_gb=${DISK_GB} -p cpu_arch=${ARCH} -p capabilities="boot_mode:bios" -n cc0

#Add the associated port(s) MAC address to the created node(s)
CC0_NODE_UUID=`ironic node-list | grep cc0 | awk '{print $2}'`
ironic port-create -n ${CC0_NODE_UUID} -a ${cc_mac[0]}

#Add the instance_info/image_source and instance_info/root_gb
ironic node-update ${CC0_NODE_UUID} add instance_info/image_source=${WHOLE_DISK_IMAGE_UUID} instance_info/root_gb=50


