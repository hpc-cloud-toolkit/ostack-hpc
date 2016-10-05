set -x
source ~/keystonrc_admin
for ((i=0; i < ${num_ccomputes}; i++)); do
    neutron port-create sharednet1 --fixed-ip ip_address=${cc_ip[$i]} --name ${cnodename_prefix}$((i+1)) --mac-address ${cc_mac[$i]}
    NEUTRON_PORT_ID_CC[$i]=`neutron port-list | grep ${cnodename_prefix}$((i+1)) | awk '{print $2}'`
    echo ${NEUTRON_PORT_ID_CC[$i]}
done

