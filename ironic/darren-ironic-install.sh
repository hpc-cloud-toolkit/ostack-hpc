#!/bin/bash
#---------------------------------------------------------------------------------
#This script installs and configures ironic for baremetal provisioning on CentOS 7
#Using the OpenStack-Mitaka release
#This relies on the packstack installation to happen first.
#---------------------------------------------------------------------------------

#Set SELinux to permissive
setenforce 0

#Create roles for the baremetal service. These can be used later to give special permissions to baremetal. This script will be using the defaults.
openstack role list | grep -i baremetal_admin
role_exists=$?
if [ "${role_exists}" -ne "0" ]; then 
    openstack role create baremetal_admin
fi

openstack role list | grep -i baremetal_observer
role_exists=$?
if [ "${role_exists}" -ne "0" ]; then 
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
mv /etc/xinetd.d/tftp /etc/xinetd.d/tftp.bak
cp tftp /etc/xinetd.d/

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

#Edit /etc/ironic/ironic.conf file with the <controller_ip> variable's value
sed --in-place "s|#tftp_server=\$my_ip|tftp_server=${controller_ip}|" /etc/ironic/ironic.conf
sed --in-place "s|#tftp_root=/tftpboot|tftp_root=/tftpboot|" /etc/ironic/ironic.conf
sed --in-place "s|#ip_version=4|ip_version=4|" /etc/ironic/ironic.conf

#Edit the /etc/nova/nova.conf file
sed --in-place "s|reserved_host_memory_mb=512|reserved_host_memory_mb=0|" /etc/nova/nova.conf
sed --in-place "s|#scheduler_host_subset_size=1|scheduler_host_subset_size=9999999|" /etc/nova/nova.conf
sed --in-place "s|#scheduler_use_baremetal_filters=false|scheduler_use_baremetal_filters=True|" /etc/nova/nova.conf

#Restart ironic, nova, and ovs to load in the new configuration
systemctl restart neutron-dhcp-agent
systemctl restart neutron-openvswitch-agent
systemctl restart neutron-metadata-agent
systemctl restart openstack-nova-scheduler
systemctl restart openstack-nova-compute
systemctl restart openstack-ironic-conductor

#Source the keystonerc_admin file
source ${HOME}/keystonerc_admin

#Get the tenant ID for the services tenant
SERVICES_TENANT_ID=`keystone tenant-list | grep services | awk '{print $2}'`

#Create the flat network on which you are going to launch instances
neutron net-list | grep sharednet1
net_exists=$?
if [ "${net_exists}" -ne "0" ]; then
    neutron net-create --tenant-id ${SERVICES_TENANT_ID} sharednet1 --shared --provider:network_type flat --provider:physical_network physnet1
fi
NEUTRON_NETWORK_UUID=`neutron net-list | grep sharednet1 | awk '{print $2}'`

#Create the subnet on the newly created network
neutron subnet-list | grep subnet01
subnet_exists=$?
if [ "${subnet_exists}" -ne "0" ]; then
    neutron subnet-create sharednet1 --name subnet01 --ip-version=4 --gateway=${controller_ip} --allocation-pool start=${c_subnet_dhcp_start},end=${c_subnet_dhcp_end} --enable-dhcp ${c_subnet_cidr}
fi
NEUTRON_SUBNET_UUID=`neutron subnet-list | grep subnet01 | awk '{print $2}'`

#Restart the ironic-conductor service
systemctl restart openstack-ironic-conductor

#Create the whole-disk-image from the qcow2 file
glance image-list | grep whole-disk-image
img_exists=$?
if [ "${img_exists}" -ne "0" ]; then
    glance image-create --name whole-disk-image --visibility public --disk-format qcow2 --container-format bare < ${chpc_image_user}
fi
WHOLE_DISK_IMAGE_UUID=`glance image-list | grep whole-disk-image | awk '{print $2}'`

#Create the deploy-kernel and deploy-initrd images
glance image-list | grep deploy-vmlinuz
img_exists=$?
if [ "${img_exists}" -ne "0" ]; then
    glance image-create --name deploy-vmlinuz --visibility public --disk-format aki --container-format aki < ${chpc_image_deploy_kernel}
fi
DEPLOY_VMLINUZ_UUID=`glance image-list | grep deploy-vmlinuz | awk '{print $2}'`

glance image-list | grep deploy-initrd
img_exists=$?
if [ "${img_exists}" -ne "0" ]; then
    glance image-create --name deploy-initrd --visibility public --disk-format ari --container-format ari < ${chpc_image_deploy_ramdisk}
fi
DEPLOY_INITRD_UUID=`glance image-list | grep deploy-initrd | awk '{print $2}'`

#Create the baremetal flavor and set the architecture to x86_64
nova flavor-list | grep baremetal-flavor
flavor_exists=$?
if [ "$flavor_exists" -ne "0" ]; then
    nova flavor-create baremetal-flavor baremetal-flavor ${RAM_MB} ${DISK_GB} ${CPU}
    nova flavor-key baremetal-flavor set cpu_arch=$ARCH
    nova flavor-key baremetal-flavor set capabilities:boot_option="bios"
fi
FLAVOR_UUID=`nova flavor-list | grep baremetal-flavor | awk '{print $2}'`

#Create a node in the bare metal service
ironic node-list | grep cc0
node_exists=$?
if [ "${node_exists}" -ne "0" ]; then
    ironic node-create -d pxe_ipmitool -i deploy_kernel=${DEPLOY_VMLINUZ_UUID} -i deploy_ramdisk=${DEPLOY_INITRD_UUID} -i ipmi_terminal_port=8023 -i ipmi_address=${cc_bmc[0]} -i ipmi_username=${c_bmc_username} -i ipmi_password=${c_bmc_password} -p cpus=${CPU} -p memory_mb=${RAM_MB} -p local_gb=${DISK_GB} -p cpu_arch=${ARCH} -p capabilities="boot_mode:bios" -n cc0
fi
CC0_NODE_UUID=`ironic node-list | grep cc0 | awk '{print $2}'`

#Add the associated port(s) MAC address to the created node(s)
ironic port-create -n ${CC0_NODE_UUID} -a ${cc_mac[0]}

#Add the instance_info/image_source and instance_info/root_gb
ironic node-update ${CC0_NODE_UUID} add instance_info/image_source=${WHOLE_DISK_IMAGE_UUID} instance_info/root_gb=50

#Increase the Quota limit for admin to allow nova boot
openstack quota set --ram 512000 --cores 1000 admin

#Register SSH keys with Nova
nova keypair-list | grep ostack_key
keypair_exists=$?
if [ "${keypair_exists}" -ne "0" ]; then
    nova keypair-add --pub-key ${HOME}/.ssh/id_rsa.pub ostack_key
fi

KEYPAIR_NAME=ostack_key

#Boot the node with nova
nova boot --config-drive true --flavor ${FLAVOR_UUID} --image ${WHOLE_DISK_IMAGE_UUID} --key-name ${KEYPAIR_NAME} cc0
