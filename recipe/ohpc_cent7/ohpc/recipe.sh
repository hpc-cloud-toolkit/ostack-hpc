#!/bin/bash
# -----------------------------------------------------------------------------------------
#  Example Installation Script Template
#  
#  This convenience script encapsulates command-line instructions highlighted in
#  the OpenHPC Install Guide that can be used as a starting point to perform a local
#  cluster install beginning with bare-metal. Necessary inputs that describe local
#  hardware characteristics, desired network settings, and other customizations
#  are controlled via a companion input file that is used to initialize variables 
#  within this script.
#   
#  Please see the OpenHPC Install Guide for more information regarding the
#  procedure. Note that the section numbering included in this script refers to
#  corresponding sections from the install guide.
# -----------------------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then echo "ERROR: Please run $0 as root"; exit 1; fi

#inputFile=${OHPC_INPUT_LOCAL:-/opt/ohpc/pub/doc/recipes/vanilla/input.local}
inputFile=${OHPC_INPUT_LOCAL}

if [ ! -e ${inputFile} ];then
   echo "Error: Unable to access local input file -> ${inputFile}"
   exit 1
else
   . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
fi

_BADCOUNT=0

for((i=0; i<${#c_ip[@]}; i++)) ; do
  if ! [[ ${c_ip[i]} =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([\
                            0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "ERROR: Invalid IP address #$i: ${c_ip[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
  if ! [[ ${c_bmc[i]} =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([\
                             0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "ERROR: Invalid BMC IP address #$i: ${c_bmc[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
  if ! [[ `echo ${c_mac[i]^^} | egrep "^([0-9A-F]{2}:){5}[0-9A-F]{2}$"` ]]; then
    echo "ERROR: Invalid MAC address #$i: ${c_mac[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
done

[[ $_BADCOUNT -eq 0 ]] || exit 3

# Determine number of computes and their hostnames
export num_computes=${num_computes:-${#c_ip[@]}}
for((i=0; i<${num_computes}; i++)) ; do
   c_name[$i]=${nodename_prefix}$((i+1))
done
export c_name

# ---------------------------- Begin OpenHPC Recipe ---------------------------------------
# Commands below are extracted from an OpenHPC install guide recipe and are intended for 
# execution on the master SMS host.
# -----------------------------------------------------------------------------------------

# Verify OpenHPC repository has been enabled before proceeding

yum repolist | grep -q OpenHPC
if [ $? -ne 0 ];then
   echo "Error: OpenHPC repository must be enabled locally"
   exit 1
fi

# ------------------------------------------------------------
# Add baseline OpenHPC and provisioning services (Section 3.3)
# ------------------------------------------------------------
yum -y groupinstall ohpc-base

# Cloud HPC does not use Warewulf for provisioning
#yum -y groupinstall ohpc-warewulf

# Disabling of firwall is specific to warewulf usecase
# Disable firewall 
#systemctl disable firewalld
#systemctl stop firewalld

# Enable NTP services on SMS host
systemctl enable ntpd.service
echo "server ${ntp_server}" >> /etc/ntp.conf
systemctl restart ntpd

# -------------------------------------------------------------
# Add resource management services on master node (Section 3.4)
# -------------------------------------------------------------
yum -y groupinstall ohpc-slurm-server
useradd slurm

# ------------------------------------------------------------
# Add InfiniBand support services on master node (Section 3.5)
# ------------------------------------------------------------
yum -y groupinstall "InfiniBand Support"
yum -y install infinipath-psm
systemctl start rdma

if [[ ${enable_ipoib} -eq 1 ]];then
     # Enable ib0
     cp /opt/ohpc/pub/examples/network/centos/ifcfg-ib0 /etc/sysconfig/network-scripts
     perl -pi -e "s/master_ipoib/${sms_ipoib}/" /etc/sysconfig/network-scripts/ifcfg-ib0
     perl -pi -e "s/ipoib_netmask/${ipoib_netmask}/" /etc/sysconfig/network-scripts/ifcfg-ib0
     ifup ib0
fi

# -----------------------------------------------------------
# Complete basic Warewulf setup for master node (Section 3.6)
# -----------------------------------------------------------
# Cloud HPC does not use Warewulf for provisioning, so we skip warewulf specific steps
#perl -pi -e "s/device = eth1/device = ${sms_eth_internal}/" /etc/warewulf/provision.conf
#perl -pi -e "s/^\s+disable\s+= yes/ disable = no/" /etc/xinetd.d/tftp
#export MODFILE=/etc/httpd/conf.d/warewulf-httpd.conf
#perl -pi -e "s/cgi-bin>\$/cgi-bin>\n Require all granted/" $MODFILE
#perl -pi -e "s/Allow from all/Require all granted/" $MODFILE
#perl -ni -e "print unless /^\s+Order allow,deny/" $MODFILE
#ifconfig ${sms_eth_internal} ${sms_ip} netmask ${internal_netmask} up
#systemctl restart xinetd
#systemctl enable mariadb.service
#systemctl restart mariadb
#systemctl enable httpd.service
#systemctl restart httpd
#if [ ! -z ${BOS_MIRROR+x} ]; then
#     perl -pi -e "s#^YUM_MIRROR=(\S+)#YUM_MIRROR=${BOS_MIRROR}#" /usr/libexec/warewulf/wwmkchroot/centos-7.tmpl
#fi

# -------------------------------------------------
# Create compute image for Warewulf (Section 3.7.1)
# -------------------------------------------------
#export CHROOT=/opt/ohpc/admin/images/centos7.2
#wwmkchroot centos-7 $CHROOT

# -------------------------------------------------------
# Add OpenHPC components to compute image (Section 3.7.2)
# -------------------------------------------------------
#cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf

# Add OpenHPC components to compute instance
#yum -y --installroot=$CHROOT groupinstall ohpc-slurm-client
#yum -y --installroot=$CHROOT groupinstall "InfiniBand Support"
#yum -y --installroot=$CHROOT install infinipath-psm
#chroot $CHROOT systemctl enable rdma
#yum -y --installroot=$CHROOT install ntp
#yum -y --installroot=$CHROOT install kernel
#yum -y --installroot=$CHROOT install lmod-ohpc

# ----------------------------------------------
# Customize system configuration (Section 3.7.3)
# ----------------------------------------------
#wwinit ssh_keys
#cat ~/.ssh/cluster.pub >> $CHROOT/root/.ssh/authorized_keys
#echo "${sms_ip}:/home /home nfs nfsvers=3,rsize=1024,wsize=1024,cto 0 0" >> $CHROOT/etc/fstab
#echo "${sms_ip}:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3 0 0" >> $CHROOT/etc/fstab
perl -pi -e "s/ControlMachine=\S+/ControlMachine=${sms_name}/" /etc/slurm/slurm.conf
echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports
echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports
exportfs -a
systemctl restart nfs
systemctl enable nfs-server
#chroot $CHROOT systemctl enable ntpd
#echo "server ${sms_ip}" >> $CHROOT/etc/ntp.conf

# Update basic slurm configuration if additional computes defined
if [ ${num_computes} -gt 4 ];then
   perl -pi -e "s/^NodeName=(\S+)/NodeName=${nodename_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=${nodename_prefix}[1-${num_computes}]/" /etc/slurm/slurm.conf
   #perl -pi -e "s/^NodeName=(\S+)/NodeName=c[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
   #perl -pi -e "s/^PartitionName=normal Nodes=(\S+)/PartitionName=normal Nodes=c[1-${num_computes}]/" $CHROOT/etc/slurm/slurm.conf
fi

# -----------------------------------------
# Additional customizations (Section 3.7.4)
# -----------------------------------------
echo "* soft memlock unlimited" >> /etc/security/limits.conf
echo "* hard memlock unlimited" >> /etc/security/limits.conf
#echo "* soft memlock unlimited" >> $CHROOT/etc/security/limits.conf
#echo "* hard memlock unlimited" >> $CHROOT/etc/security/limits.conf

# Enable slurm pam module
#echo "account    required     pam_slurm.so" >> $CHROOT/etc/pam.d/sshd

# Enable Optional packages

if [[ ${enable_lustre_client} -eq 1 ]];then
     # Install Lustre client on master
     yum -y install lustre-client-ohpc lustre-client-ohpc-modules

     # Enable lustre in WW compute image
     #yum -y --installroot=$CHROOT install lustre-client-ohpc lustre-client-ohpc-modules
     #mkdir $CHROOT/mnt/lustre
     #echo "${mgs_fs_name} /mnt/lustre lustre defaults,_netdev,localflock 0 0" >> $CHROOT/etc/fstab

     # Enable o2ib for Lustre
     echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
     #echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf

     # mount Lustre client on master
     mkdir /mnt/lustre
     mount -t lustre -o localflock ${mgs_fs_name} /mnt/lustre
fi

if [[ ${enable_nagios} -eq 1 ]];then
     # Install Nagios on master and vnfs image
     yum -y groupinstall ohpc-nagios

     #yum -y --installroot=$CHROOT groupinstall ohpc-nagios

     #chroot $CHROOT systemctl enable nrpe
     #perl -pi -e "s/^allowed_hosts=/# allowed_hosts=/" $CHROOT/etc/nagios/nrpe.cfg
     #echo "nrpe 5666/tcp # NRPE"         >> $CHROOT/etc/services
     #echo "nrpe : ${sms_ip}  : ALLOW"    >> $CHROOT/etc/hosts.allow
     #echo "nrpe : ALL : DENY"            >> $CHROOT/etc/hosts.allow
     #chroot $CHROOT /usr/sbin/useradd -c "NRPE user for the NRPE service" -d /var/run/nrpe -r -g nrpe -s /sbin/nologin nrpe
     #chroot $CHROOT /usr/sbin/groupadd -r nrpe
     mv /etc/nagios/conf.d/services.cfg.example /etc/nagios/conf.d/services.cfg
     mv /etc/nagios/conf.d/hosts.cfg.example /etc/nagios/conf.d/hosts.cfg
     for ((i=0; i<$num_computes; i++)) ; do
        perl -pi -e "s/HOSTNAME$(($i+1))/${c_name[$i]}/ || s/HOST$(($i+1))_IP/${c_ip[$i]}/" \
        /etc/nagios/conf.d/hosts.cfg
     done
     perl -pi -e "s/ \/bin\/mail/ \/usr\/bin\/mailx/g" /etc/nagios/objects/commands.cfg
     perl -pi -e "s/nagios\@localhost/root\@${sms_name}/" /etc/nagios/objects/contacts.cfg
     #echo command[check_ssh]=/usr/lib64/nagios/plugins/check_ssh localhost >> $CHROOT/etc/nagios/nrpe.cfg
     chkconfig nagios on
     systemctl start nagios
     chmod u+s `which ping`
fi

if [[ ${enable_ganglia} -eq 1 ]];then
     # Install Ganglia on master
     yum -y groupinstall ohpc-ganglia
     # Install Ganglia on compute node image
     #yum -y --installroot=$CHROOT install ganglia-gmond-ohpc

     cp /opt/ohpc/pub/examples/ganglia/gmond.conf /etc/ganglia/gmond.conf
     perl -pi -e "s/<sms>/${sms_name}/" /etc/ganglia/gmond.conf

     #cp /etc/ganglia/gmond.conf $CHROOT/etc/ganglia/gmond.conf
     echo "gridname MySite" >> /etc/ganglia/gmetad.conf
     systemctl enable gmond
     systemctl enable gmetad
     systemctl start gmond
     systemctl start gmetad
     #chroot $CHROOT systemctl enable gmond
     systemctl try-restart httpd
fi

if [[ ${enable_clustershell} -eq 1 ]];then
     # Install clustershell
     yum -y install clustershell-ohpc
     cd /etc/clustershell/groups.d
     mv local.cfg local.cfg.orig
     echo "adm: ${sms_name}" > local.cfg
     echo "compute: ${nodename_prefix}[1-${num_computes}]" >> local.cfg
     echo "all: @adm,@compute" >> local.cfg
fi

if [[ ${enable_mrsh} -eq 1 ]];then
     # Install mrsh
     yum -y install mrsh-ohpc mrsh-rsh-compat-ohpc
     #yum -y --installroot=$CHROOT install mrsh-ohpc mrsh-rsh-compat-ohpc mrsh-server-ohpc
     echo "mshell          21212/tcp                  # mrshd" >> /etc/services
     echo "mlogin            541/tcp                  # mrlogind" >> /etc/services
     #chroot $CHROOT systemctl enable xinetd
fi

if [[ ${enable_genders} -eq 1 ]];then
     # Install genders
     yum -y install genders-ohpc
     echo -e "${sms_name}\tsms" > /etc/genders
     for ((i=0; i<$num_computes; i++)) ; do
        echo -e "${c_name[$i]}\tcompute,bmc=${c_bmc[$i]}"
     done >> /etc/genders
fi

# Optionally, enable conman and configure
if [[ ${enable_ipmisol} -eq 1 ]];then
     yum -y install conman-ohpc
     for ((i=0; i<$num_computes; i++)) ; do
        echo -n 'CONSOLE name="'${c_name[$i]}'" dev="ipmi:'${c_bmc[$i]}'" '
        echo 'ipmiopts="'U:${bmc_username},P:${bmc_password},W:solpayloadsize'"'
     done >> /etc/conman.conf
     systemctl enable conman
     systemctl start conman
fi

# --------------------------------------------------------
# Configure rsyslog on SMS and computes (Section 3.7.4.10)
# --------------------------------------------------------
perl -pi -e "s/\\#\\\$ModLoad imudp/\\\$ModLoad imudp/" /etc/rsyslog.conf
perl -pi -e "s/\\#\\\$UDPServerRun 514/\\\$UDPServerRun 514/" /etc/rsyslog.conf
systemctl restart rsyslog
#echo "*.* @${sms_ip}:514" >> $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^cron/\\#cron/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^uucp/\\#uucp/" $CHROOT/etc/rsyslog.conf

# ----------------------------
# Import files (Section 3.7.5)
# ----------------------------
#wwsh file import /etc/passwd
#wwsh file import /etc/group
#wwsh file import /etc/shadow 
#wwsh file import /etc/slurm/slurm.conf
#wwsh file import /etc/munge/munge.key

#if [[ ${enable_ipoib} -eq 1 ]];then
#     wwsh file import /opt/ohpc/pub/examples/network/centos/ifcfg-ib0.ww
#     wwsh -y file set ifcfg-ib0.ww --path=/etc/sysconfig/network-scripts/ifcfg-ib0
#fi

# --------------------------------------
# Assemble bootstrap image (Section 3.8)
# --------------------------------------
#export WW_CONF=/etc/warewulf/bootstrap.conf
#echo "drivers += updates/kernel/" >> $WW_CONF
#wwbootstrap `uname -r`
# Assemble VNFS
#wwvnfs -y --chroot $CHROOT
# Add hosts to cluster
#echo "GATEWAYDEV=${eth_provision}" > /tmp/network.$$
#wwsh -y file import /tmp/network.$$ --name network
#wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0
#for ((i=0; i<$num_computes; i++)) ; do
#   wwsh -y node new ${c_name[i]} --ipaddr=${c_ip[i]} --hwaddr=${c_mac[i]} -D ${eth_provision}
#done
# Add hosts to cluster (Cont.)
#wwsh -y provision set "${compute_regex}" --vnfs=centos7.2 --bootstrap=`uname -r` --files=dynamic_hosts,passwd,group,shadow,slurm.conf,munge.key,network

# Optionally, add arguments to bootstrap kernel
#if [[ ${enable_kargs} ]]; then
#   wwsh provision set "${compute_regex}" --kargs=${kargs}
#fi

# Restart ganglia services to pick up hostfile changes
if [[ ${enable_ganglia} -eq 1 ]];then
  systemctl restart gmond
  systemctl restart gmetad
fi

# Optionally, define IPoIB network settings (required if planning to mount Lustre over IB)
#if [[ ${enable_ipoib} -eq 1 ]];then
#     for ((i=0; i<$num_computes; i++)) ; do
#        wwsh -y node set ${c_name[$i]} -D ib0 --ipaddr=${c_ipoib[$i]} --netmask=${ipoib_netmask}
#     done
#     wwsh -y provision set "${compute_regex}" --fileadd=ifcfg-ib0.ww
#fi

#systemctl restart dhcpd
#wwsh pxe update

# Optionally, enable console redirection 
#if [[ ${enable_ipmisol} -eq 1 ]];then
#     wwsh -y provision set "${compute_regex}" --kargs "${kargs} console=ttyS1,115200"
#fi

# --------------------------------
# Boot compute nodes (Section 3.9)
# --------------------------------
#for ((i=0; i<${num_computes}; i++)) ; do
#   ipmitool -E -I lanplus -H ${c_bmc[$i]} -U ${bmc_username} chassis power reset
#done

# ---------------------------------------
# Install Development Tools (Section 4.1)
# ---------------------------------------
yum -y groupinstall ohpc-autotools
yum -y install valgrind-ohpc
yum -y install EasyBuild-ohpc
yum -y install spack-ohpc
yum -y install R_base-ohpc            

# -------------------------------
# Install Compilers (Section 4.2)
# -------------------------------
yum -y install gnu-compilers-ohpc

# --------------------------------
# Install MPI Stacks (Section 4.3)
# --------------------------------
yum -y install openmpi-gnu-ohpc mvapich2-gnu-ohpc

# ---------------------------------------
# Install Performance Tools (Section 4.4)
# ---------------------------------------
yum -y groupinstall ohpc-perf-tools-gnu
yum -y install lmod-defaults-gnu-mvapich2-ohpc

# ---------------------------------------------------
# Install 3rd Party Libraries and Tools (Section 4.6)
# ---------------------------------------------------
yum -y groupinstall ohpc-serial-libs-gnu
yum -y groupinstall ohpc-parallel-libs-gnu
yum -y groupinstall ohpc-io-libs-gnu
yum -y groupinstall ohpc-python-libs-gnu
yum -y groupinstall ohpc-runtimes-gnu

# -----------------------------------------------------------------------------------
# Install Optional Development Tools for use with Intel Parallel Studio (Section 4.7)
# -----------------------------------------------------------------------------------
if [[ ${enable_intel_packages} -eq 1 ]];then
     yum -y install intel-compilers-devel-ohpc
     yum -y install intel-mpi-devel-ohpc
     yum -y groupinstall ohpc-serial-libs-intel
     yum -y groupinstall ohpc-parallel-libs-intel
     yum -y groupinstall ohpc-io-libs-intel
     yum -y groupinstall ohpc-perf-tools-intel
     yum -y groupinstall ohpc-python-libs-intel
     yum -y groupinstall ohpc-runtimes-intel
fi

# -------------------------------------------------------------
# Allow for optional sleep to wait for provisioning to complete
# -------------------------------------------------------------
#sleep ${provision_wait}

# ------------------------------------
# Resource Manager Startup (Section 5)
# ------------------------------------
systemctl enable munge
systemctl enable slurmctld
systemctl start munge
systemctl start slurmctld

echo "==========================================================="
echo "<< Finished installing OpenHPC on SMS node: ${sms_name} >>"
echo "==========================================================="

#pdsh -P normal systemctl start slurmd
#useradd -m test
#wwsh file resync passwd shadow group
#pdsh -P normal /warewulf/bin/wwgetfiles 
