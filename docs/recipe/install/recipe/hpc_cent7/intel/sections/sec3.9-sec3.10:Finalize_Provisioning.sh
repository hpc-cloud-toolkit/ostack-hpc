
## FILE: hpc_cent7/intel/sections/sec3.9-sec3.10:Finalize_Provisioning.sh
#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Finalize Provisioning (Section 3.9)-(Section 3.10)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
# --------------------------------------------------
# Finalize Provisioning (Section 3.9)-(Section 3.10)
# --------------------------------------------------
# for HPC Cloud no warewulf so commenting thoese parts
#export WW_CONF=/etc/warewulf/bootstrap.conf
#echo "drivers += updates/kernel/" >> $WW_CONF
#wwbootstrap `uname -r`
## if [[ ${enable_stateful} -ne 1 ]];then
#     # Assemble VNFS
#     wwvnfs -y --chroot $CHROOT
## fi
## Add hosts to cluster
# HPC Cloud these might be taken care  post boot, or openstack will take care of networking
# TBD Need to register node via Nova API
#echo "GATEWAYDEV=${eth_provision}" > /tmp/network.$$
#wwsh -y file import /tmp/network.$$ --name network
#wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
#for ((i=0; i<$num_computes; i++)) ; do
#   wwsh -y node new ${c_name[i]} --ipaddr=${c_ip[i]} --hwaddr=${c_mac[i]} -D ${eth_provision}
#done
# some of the files will be transfered via cloud init or post boot, files like slurm.conf,munge.key
## Add hosts to cluster (Cont.)
#wwsh -y provision set "${nodename_prefix}*" --vnfs=rhel7.2 --bootstrap=`uname -r` \
# --files=dynamic_hosts,passwd,group,shadow,slurm.conf,slurm,munge.key,network
# Optionally, add arguments to bootstrap kernel
#if [[ ${enable_kargs} ]]; then
#   wwsh provision set "${nodename_prefix}*" --kargs=${kargs}
#fi
# Restart ganglia services to pick up hostfile changes
if [[ ${enable_ganglia} -eq 1 ]];then
  systemctl restart gmond
  systemctl restart gmetad
fi
# Optionally, define IPoIB network settings (required if planning to mount Lustre over IB)
if [[ ${enable_ipoib} -eq 1 ]];then
     for ((i=0; i<$num_computes; i++)) ; do
        wwsh -y node set ${c_name[$i]} -D ib0 --ipaddr=${c_ipoib[$i]} --netmask=${ipoib_netmask}
     done
     wwsh -y provision set "${nodename_prefix}*" --fileadd=ifcfg-ib0.ww
fi
#No warewulf so comment these
#systemctl restart dhcpd
#wwsh pxe update || true
# Optionally, enable console redirection 
if [[ ${enable_ipmisol} -eq 1 ]];then
     wwsh -y provision set "${nodename_prefix}*" --kargs "${kargs} console=ttyS0,115200"
fi
# No warewulf
#if [[ ${enable_stateful} -eq 1 ]];then
#     # Add stateful provisioning support
#     yum -y --installroot=$CHROOT install grub2
#     wwvnfs -y --chroot $CHROOT
#fi
if [[ ${enable_stateful} -eq 1 ]];then
     # Add stateful node object parameters
     export sd1="mountpoint=/boot:dev=${stateful_dev}1:type=ext3:size=500"
     export sd2="dev=${stateful_dev}2:type=swap:size=32768"
     export sd3="mountpoint=/:dev=${stateful_dev}3:type=ext3:size=fill"
     for ((i=0; i<$num_computes; i++)); do
        wwsh -y object modify -s bootloader=${stateful_dev} -t node ${c_name[$i]};
        wwsh -y object modify -s diskpartition=${stateful_dev} -t node ${c_name[$i]};
        wwsh -y object modify -s \
        diskformat=${stateful_dev}1,${stateful_dev}2,${stateful_dev}3 -t node ${c_name[$i]};
        wwsh -y object modify -s filesystems="$sd1,$sd2,$sd3" -t node ${c_name[$i]};
     done
fi
# Here update the post provision script
# Create baremetal flavor with Nova
# register nodes with Nova
# register files with Nova
# restart the nodes with Nova or ironic
# then copy Postboot files to compute node
#for ((i=0; i<${num_computes}; i++)) ; do
#   ipmitool -E -I lanplus -H ${c_bmc[$i]} -U ${bmc_username} chassis power reset
#done
# wait for compute nodes to come up
sleep ${provision_wait}
# prevent re-imaging stateful nodes
#if [[ ${enable_stateful} -eq 1 ]];then
#  for ((i=0; i<$num_computes; i++)) ; do
#    wwsh -y object modify -s bootlocal=EXIT ${c_name[$i]};
#  done
#fi
true
#  
