# PREMITIVE README, TO BE REVISED

-----------------
Install packstack
-----------------
Modify answer.txt and change the following line:
CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-eth2:enp5s0f1
update enp5s0f1 to match your network interface.

Run packstack-install.sh -s=<controller_ip> -f=<flat_network_range>

example:
./packstack-install.sh -s=192.168.46.2 -f=192.168.46.0/24