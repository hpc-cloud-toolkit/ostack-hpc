# PREMITIVE README, TO BE REVISED

----------------------------
Source the openstack rc file
----------------------------
# you need these information for executing all the openstack command later in this document
source keystonerc_admin

-------------------------------
Sample keystonerc_admin RC file
-------------------------------
unset OS_SERVICE_TOKEN
export OS_USERNAME=admin
export OS_PASSWORD=28bc7ba0c7024003
export OS_AUTH_URL=http://172.16.2.9:5000/v2.0
export PS1='[\u@\h \W(keystone_admin)]\$ '

export OS_TENANT_NAME=admin
export OS_REGION_NAME=RegionOne

--------------------------------------------
Create a neutron network for baremetal nodes
--------------------------------------------
# Retrieve the admin tenant-id which will be used later for neutron net-create
openstack project list | grep admin | awk '{print $2}

# Create a neutron network 
# This uses flat network type
# The physnet1 should match the one you configured at packstack answer file/ml2_conf.ini
# The TENANT_ID is the admin tenant-id that you get from previous command
neutron net-create --tenant-id $TENANT_ID sharednet1 --shared --provider:network_type flat --provider:physical_network physnet1

# Create the subnet info for the above neutron network
# This uses neutron dhcp service
# NETWORK_CIDR, GATEWAY_IP, $START_IP, $END_IP of the allocation pool should be assigned by your network administrator 
# Making sure your neutron network is routed through your network/internet
# neutron subnet-create sharednet1 $NETWORK_CIDR --name $SUBNET_NAME --ip-version=4 --gateway=$GATEWAY_IP --allocation-pool start=$START_IP,end=$END_IP --enable-dhcp
neutron subnet-create sharednet1 10.0.100.0/16 --name sharedsubnet1 --ip-version=4 --gateway=10.0.2.1 --allocation-pool start=10.0.100.1,end=10.0.100.250 --enable-dhcp

------------------
UPLOAD USER IMAGE
------------------
# the user image can be created by the disk image builder.
# this example uses wholedisk image
glance image-create --name ironic-user-ubuntu --visibility public --disk-format qcow2 --container-format bare < ironic-user-ubuntu.qcow2

-------------------
UPLOAD DEPLOY IMAGE
-------------------
# upload the deploy kernel image
# note down the glance uuid ($DEPLOY_VMLINUZ_UUID) which will be used later for ironic node enrollment
glance image-create --name ironic-deploy-kernel --visibility public --disk-format aki --container-format aki < ironic-deploy.kernel

# upload the deploy initramfs image
# note down the glance uuid ($DEPLOY_INITRD_UUID) which will be used later for ironic node enrollment
glance image-create --name ironic-deploy-initrd --visibility public --disk-format ari --container-format ari < ironic-deploy.initramfs

------------------
Create nova flavor
------------------
# nova flavor-create $name $flavor-id $mem $disk $cpu
nova flavor-create my-baremetal-flavor 1001 131072 200 72

# set flavor architecture and deploy images
nova flavor-key my-baremetal-flavor set cpu_arch=x86_64 "baremetal:deploy_kernel_id"=$DEPLOY_VMLINUZ_UUID "baremetal:deploy_ramdisk_id"=$DEPLOY_INITRD_UUID

# By default, nova scheduler uses "ExactRamFilter,ExactDiskFilter,ExactCoreFilter". 
# The nova/ironic provisioning will fail (i.e. Host Not Found error) if the cpu, mem, disk does not match between the "flavor" and "ironic-node properties".

----------------
Create a keypair
----------------
#openstack keypair create --public-key $PATH_TO_PUB_KEY #KEYPAIR_NAME
openstack keypair create --public-key /path/to/keypair.pub ironic.key

-------------------
Set OpenStack quota 
-------------------
# The default quota for admin project is  51200 memmory and 20 cores
# This might not be sufficient for your physical nodes requirements.
# Ironic provisioning will fail if the cpu/mem of the physical nodes exceeded this limit.
# openstack quota set --ram 512000 --cores 1000 $TENANT_NAME
openstack quota set --ram 512000 --cores 1000 admin

------------------
Enroll ironic node
------------------
Refer ironic-node-create.sh 
# TODO: document this section

------
Others
------
# After sucessful enrollment, you can see the stats from nova hypervisor
# The stats updates might take a short-while to reflect the new changes after enrollment 
# nova boot will fail if there is not enough hypervisor/host available
openstack hypervisor stats show
