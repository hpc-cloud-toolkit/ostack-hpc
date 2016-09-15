# PREMITIVE README, TO BE REVISED

-----------------
Install packstack
-----------------
Refer files/packstac-install.sh and files/answer.txt

packstack --answer-file=answer.txt

The openrc files will be created after packstack installation.
You need the information inside the rc file for interacting with OpenStack

-------------------------------
Sample keystonerc_admin RC file
-------------------------------
unset OS_SERVICE_TOKEN
export OS_USERNAME=admin
export OS_PASSWORD=XXXXXXXXXX
export OS_AUTH_URL=http://172.16.2.9:5000/v2.0
export PS1='[\u@\h \W(keystone_admin)]\$ '

export OS_TENANT_NAME=admin
export OS_REGION_NAME=RegionOne

--------------------------------------
Validate /etc/nova/nova.conf nova.conf 
--------------------------------------
[default]

# Driver to use for controlling virtualization. Options
# include: libvirt.LibvirtDriver, xenapi.XenAPIDriver,
# fake.FakeDriver, baremetal.BareMetalDriver,
# vmwareapi.VMwareESXDriver, vmwareapi.VMwareVCDriver (string
# value)
#compute_driver=<None>
compute_driver=ironic.IronicDriver

# Firewall driver (defaults to hypervisor specific iptables
# driver) (string value)
#firewall_driver=<None>
firewall_driver=nova.virt.firewall.NoopFirewallDriver

# The scheduler host manager class to use (string value)
#scheduler_host_manager=host_manager
scheduler_host_manager=ironic_host_manager

# Virtual ram to physical ram allocation ratio which affects
# all ram filters. This configuration specifies a global ratio
# for RamFilter. For AggregateRamFilter, it will fall back to
# this configuration value if no per-aggregate setting found.
# (floating point value)
#ram_allocation_ratio=1.5
ram_allocation_ratio=1.0

# Amount of disk in MB to reserve for the host (integer value)
#reserved_host_disk_mb=0
reserved_host_memory_mb=0

# Flag to decide whether to use baremetal_scheduler_default_filters or not.
# (boolean value)
#scheduler_use_baremetal_filters=False
scheduler_use_baremetal_filters=True

# Determines if the Scheduler tracks changes to instances to help with
# its filtering decisions (boolean value)
#scheduler_tracks_instance_changes=True
scheduler_tracks_instance_changes=False

# New instances will be scheduled on a host chosen randomly from a subset
# of the N best hosts, where N is the value set by this option.  Valid
# values are 1 or greater. Any value less than one will be treated as 1.
# For ironic, this should be set to a number >= the number of ironic nodes
# to more evenly distribute instances across the nodes.
#scheduler_host_subset_size=1
scheduler_host_subset_size=9999999

----------------------------------------------
Validate /etc/neutron/plugins/ml2/ml2_conf.ini 
----------------------------------------------
[ml2]
type_drivers = flat,vxlan
tenant_network_types = vxlan,flat
mechanism_drivers = openvswitch

[ml2_type_flat]
flat_networks = physnet1
# probably can just use "*" 

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True

-------------------------------------------------------
Validate /etc/neutron/plugins/ml2/openvswitch_agent.ini
-------------------------------------------------------
[ovs]
bridge_mappings = physnet1:br-eth2
# Replace eth2 with the interface on the neutron node which you
# are using to connect to the bare metal server
# This should match the setting in packstack answer file.

--------------------------------
Validate /etc/ironic/ironic.conf
--------------------------------
[neutron]
#cleaning_network_uuid = $NETWORK_UUID
cleaning_network_uuid = 4d5fd01c-4be6-4de2-b24e-68df725b809b

# this should be the tftp server ip that is reachable from baremetal nodes physnet1 for pxe process
tftp_server=10.0.2.9


You need to restart the relevant openstack services for changges to the above ini or conf files.
systemctl restart neutron-dhcp-agent
systemctl restart neutron-openvswitch-agent
systemctl restart neutron-metadata-agent
systemctl restart openstack-nova-scheduler
systemctl restart openstack-nova-compute
systemctl restart openstack-ironic-conductor

