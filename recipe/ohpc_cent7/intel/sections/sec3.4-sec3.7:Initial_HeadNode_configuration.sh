#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Initial HeadNode configuration (Section 3.4)-(Section 3.7)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

# ----------------------------------------------------------
# Initial HeadNode configuration (Section 3.4)-(Section 3.7)
# ----------------------------------------------------------

yum -y groupinstall orch-base
# No warewulf on Controller node, since we will install OpenStack
#yum -y groupinstall orch-warewulf

# Disable firewall 
rpm -q firewalld && systemctl disable firewalld
rpm -q firewalld && systemctl stop firewalld

# Enable NTP services on SMS host
systemctl enable ntpd.service
echo "server ${ntp_server}" >> /etc/ntp.conf
systemctl restart ntpd

yum -y groupinstall orch-slurm-server

getent passwd slurm || useradd slurm

perl -pi -e "s|^#UsePAM=|UsePAM=1|" /etc/slurm/slurm.conf
cat <<- HERE > /etc/pam.d/slurm
	account  required  pam_unix.so
	account  required  pam_slurm.so
	auth     required  pam_localuser.so
	session  required  pam_limits.so
	HERE

yum -y groupinstall "InfiniBand Support"
yum -y install infinipath-psm
systemctl enable rdma
systemctl start rdma


if [[ ${enable_ipoib} -eq 1 ]];then
     # Enable ib0
     cp /opt/intel/hpc-orchestrator/pub/examples/network/rhel/ifcfg-ib0 /etc/sysconfig/network-scripts
     perl -pi -e "s/master_ipoib/${sms_ipoib}/" /etc/sysconfig/network-scripts/ifcfg-ib0
     perl -pi -e "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0
     ifup ib0
fi

# No Warewulf in HPC POC, so remove this 
#perl -pi -e "s/device = eth1/device = ${sms_eth_internal}/" /etc/warewulf/provision.conf
#perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
#export MODFILE=/etc/httpd/conf.d/warewulf-httpd.conf
#perl -pi -e "s/cgi-bin>\$/cgi-bin>\n Require all granted/" $MODFILE
#perl -pi -e "s/Allow from all/Require all granted/" $MODFILE
#perl -ni -e "print unless /^\s+Order allow,deny/" $MODFILE

# Assign static IP for now comment this
#ifconfig ${sms_eth_internal} ${sms_ip} netmask ${internal_netmask} up

#these are needed for warewulf, so comment for now
#systemctl restart xinetd
#systemctl enable mariadb.service
#systemctl restart mariadb
#systemctl enable httpd.service
#systemctl restart httpd


# Install genders
yum -y install genders-orch
echo -e "${sms_name}\tsms,pdsh_all_skip" > /etc/genders
echo -e "${sms_name}\tinternal_eth=${sms_eth_internal}" > /etc/genders
for ((i=0; i<$num_computes; i++)) ; do
   echo -e "${c_name[$i]}\tcompute,bmc=${c_bmc[$i]}"
done >> /etc/genders


true
