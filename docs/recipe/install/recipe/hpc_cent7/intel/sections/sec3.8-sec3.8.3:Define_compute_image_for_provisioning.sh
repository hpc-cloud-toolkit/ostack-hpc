
## FILE: hpc_cent7/intel/sections/sec3.8-sec3.8.3:Define_compute_image_for_provisioning.sh
#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Define compute image for provisioning (Section 3.8)-(Section 3.8.3)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
# -------------------------------------------------------------------
# Define compute image for provisioning (Section 3.8)-(Section 3.8.3)
# -------------------------------------------------------------------
# For HPC Cloug POC, we are not using warewulf so comment this
#if [[ "http://BOS.mirror.requiredx" != "${BOS_MIRROR}x" ]]; then
#     perl -pi -e "s#^YUM_MIRROR=(\S*)#YUM_MIRROR=${BOS_MIRROR}#" \
#      /usr/libexec/warewulf/wwmkchroot/rhel-7.tmpl
#fi
#export CHROOT=/opt/intel/hpc-orchestrator/admin/images/rhel7.2
#wwmkchroot rhel-7 $CHROOT
#cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf
# Add components to compute instance
#yum -y --installroot=$CHROOT groupinstall orch-slurm-client
#yum -y --installroot=$CHROOT install pdsh-orch
#yum -y --installroot=$CHROOT groupinstall "InfiniBand Support"
#yum -y --installroot=$CHROOT install infinipath-psm
#chroot $CHROOT systemctl enable rdma
#yum -y --installroot=$CHROOT install ntp
#yum -y --installroot=$CHROOT install kernel
#yum -y --installroot=$CHROOT install lmod-orch
### ssh keys need to be trasfered via cloud init
#wwinit ssh_keys
#cat ~/.ssh/cluster.pub >> $CHROOT/root/.ssh/authorized_keys
# This will be done post boot via CloudInit
# nfs mount is perfromed at post boot
#echo "${sms_ip}:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0" >> $CHROOT/etc/fstab
#echo "${sms_ip}:/opt/intel/hpc-orchestrator/pub" \
# "/opt/intel/hpc-orchestrator/pub nfs nfsvers=3 0 0" \
# >> $CHROOT/etc/fstab
perl -pi -e "s/ControlMachine=\S+/ControlMachine=${sms_name}/" /etc/slurm/slurm.conf
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/intel/hpc-orchestrator/pub *(rw,no_subtree_check,fsid=11,no_root_squash)" >> /etc/exports
exportfs -a
systemctl restart nfs
systemctl enable nfs-server
#chroot $CHROOT systemctl enable ntpd
#echo "server ${sms_ip}" >> $CHROOT/etc/ntp.conf
# Update basic slurm configuration
   perl -pi -e "s/^NodeName=(\S+)/NodeName=${nodename_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=${nodename_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   #perl -pi -e "s/^NodeName=(\S+)/NodeName=${nodename_prefix}[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
   #perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=${nodename_prefix}[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
true
#  
