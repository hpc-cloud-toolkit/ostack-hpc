#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Additional Customizations (optional) (Section 3.8.4)-(Section 3.8.4.11)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

# -----------------------------------------------------------------------
# Additional Customizations (optional) (Section 3.8.4)-(Section 3.8.4.11)
# -----------------------------------------------------------------------
# For Cloud POC we are not using warewulf, and image will be created using diskimage-builder tool so comment all image creation here
#

perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' /etc/security/limits.conf
perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' /etc/security/limits.conf
##perl -pi -e 's/# End of file/\* soft memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf
##perl -pi -e 's/# End of file/\* hard memlock unlimited\n$&/s' $CHROOT/etc/security/limits.conf


if [[ ${enable_mrsh} -eq 1 ]];then
     # Install mrsh
     yum -y install mrsh-orch mrsh-rsh-compat-orch
     ##yum -y --installroot=$CHROOT install mrsh-orch mrsh-rsh-compat-orch mrsh-server-orch
     echo "mshell          21212/tcp                  # mrshd" >> /etc/services
     echo "mlogin            541/tcp                  # mrlogind" >> /etc/services
     ##chroot $CHROOT systemctl enable xinetd
fi

# Enable slurm pam module
##echo "account    required     pam_slurm.so" >> $CHROOT/etc/pam.d/sshd
##if [[ -f "$CHROOT/etc/pam.d/mrsh" && -f "$CHROOT/etc/pam.d/mrlogin" ]]; then
   ##echo "account    required     pam_slurm.so" >> $CHROOT/etc/pam.d/mrsh
   ##echo "account    required     pam_slurm.so" >> $CHROOT/etc/pam.d/mrlogin
#fi

# for now lets not use clck
#yum -y install intel-clck-orch
##yum -y --installroot=$CHROOT install intel-clck-orch
#yum -y install  intel-clck-supportability-orch


# Enable Optional packages

if [[ ${enable_lustre_client} -eq 1 ]];then
     # Install Lustre client on master
     yum -y install lustre-client-orch lustre-client-orch-modules

     # Enable lustre in WW compute image
     #yum -y --installroot=$CHROOT install lustre-client-orch lustre-client-orch-modules
     #mkdir $CHROOT/mnt/lustre
     #echo "${mgs_fs_name} /mnt/lustre lustre _netdev,lazystatfs,flock,nosuid,defaults 0 0" >> $CHROOT/etc/fstab

     # Enable o2ib for Lustre
     echo "options lnet networks=o2ib(ib0)" >> /etc/modprobe.d/lustre.conf
     #echo "options lnet networks=o2ib(ib0)" >> $CHROOT/etc/modprobe.d/lustre.conf

     # mount Lustre client on master
     mkdir /mnt/lustre
     mount -t lustre -o _netdev,lazystatfs,flock,nosuid,defaults ${mgs_fs_name} /mnt/lustre
fi


if [[ ${enable_nagios} -eq 1 ]];then
     # Install Nagios on master and vnfs image
     yum -y groupinstall orch-nagios
     #yum -y --installroot=$CHROOT groupinstall orch-nagios
     #chroot $CHROOT systemctl enable nrpe
     #perl -pi -e "s/^allowed_hosts=/# allowed_hosts=/" $CHROOT/etc/nagios/nrpe.cfg
     #echo "nrpe 5666/tcp # NRPE"         >> $CHROOT/etc/services
     #echo "nrpe : ${sms_ip}  : ALLOW"    >> $CHROOT/etc/hosts.allow
     #echo "nrpe : ALL : DENY"            >> $CHROOT/etc/hosts.allow
     #chroot $CHROOT getent group nrpe  || chroot $CHROOT /usr/sbin/groupadd -r nrpe
     #chroot $CHROOT getent passwd nrpe || chroot $CHROOT /usr/sbin/useradd -c \
      "NRPE user for the NRPE service" -d /var/run/nrpe -r -g nrpe -s /sbin/nologin nrpe
     mv /etc/nagios/conf.d/services.cfg.example /etc/nagios/conf.d/services.cfg
     mv /etc/nagios/conf.d/hosts.cfg.example /etc/nagios/conf.d/hosts.cfg
     for ((i=0; i<$num_computes; i++)) ; do
        perl -pi -e "s/HOSTNAME$(($i+1))/${c_name[$i]}/ || s/HOST$(($i+1))_IP/${c_ip[$i]}/" \
        /etc/nagios/conf.d/hosts.cfg
     done

     perl -pi -e "s/ \/bin\/mail/ \/usr\/bin\/mailx/g" /etc/nagios/objects/commands.cfg
     perl -pi -e "s/nagios\@localhost/root\@${sms_name}/" /etc/nagios/objects/contacts.cfg
     echo command[check_ssh]=/usr/lib64/nagios/plugins/check_ssh localhost \
      #>> $CHROOT/etc/nagios/nrpe.cfg
     chkconfig nagios on
     systemctl start nagios
     chmod u+s `which ping`
     mkdir /usr/share/warewulf/www
     touch /usr/share/warewulf/www/test.html
fi


if [[ ${enable_ganglia} -eq 1 ]];then
     # Install Ganglia on master
     yum -y groupinstall orch-ganglia
     #yum -y --installroot=$CHROOT install ganglia-gmond-orch
     cp /opt/intel/hpc-orchestrator/pub/examples/ganglia/gmond.conf /etc/ganglia/gmond.conf
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
     yum -y install clustershell-orch
     cd /etc/clustershell/groups.d
     mv local.cfg local.cfg.orig
     echo "adm: ${sms_name}" > local.cfg
     echo "compute: c[1-${num_computes}]" >> local.cfg
     echo "all: @adm,@compute" >> local.cfg
fi


if [[ ${enable_powerman} -eq 1 ]];then
     # Optionally, install powerman
     yum -y install powerman-orch
     cp /etc/powerman/powerman.conf{.example,}
     chown daemon:root /etc/powerman/powerman.conf
     chmod 0400 /etc/powerman/powerman.conf
     perl -pi -e 's/^\#(tcpwrappers yes)/$1/' /etc/powerman/powerman.conf
     perl -pi -e 's/^\#(listen "0.0.0.0:10101")/$1/' /etc/powerman/powerman.conf
     perl -pi -e 's/^\#(include "\/etc\/powerman\/ipmipower\.dev")/$1/' \
      /etc/powerman/powerman.conf
     for ((i=0; i<$num_computes; i++)) ; do
        perl -pi -e 'print "device \"ipmi'$i'\" \"ipmipower\" \"/usr/sbin/ipmipower -h ".
        "'${c_bmc[$i]}' -u '$bmc_username' -p ".
        "'${IPMI_PASSWORD:-undefined}'|&\"\n" if(/^\#device "ipmi1"/);' /etc/powerman/powerman.conf
     done
     for ((i=0; i<$num_computes; i++)) ; do
        perl -pi -e 'print "node \"'${c_name[$i]}'\" \"ipmi'$i'\" \"'${c_bmc[$i]}'\"\n"
        if(/^\#node "t1"/);' /etc/powerman/powerman.conf
     done
     systemctl start powerman
     pm -q
fi


# Optionally, enable conman and configure
if [[ ${enable_ipmisol} -eq 1 ]];then
     yum -y install conman-orch
     for ((i=0; i<$num_computes; i++)) ; do
        echo -n 'CONSOLE name="'${c_name[$i]}'" dev="ipmi:'${c_bmc[$i]}'" '
        echo 'ipmiopts="'U:${bmc_username},P:${IPMI_PASSWORD:-undefined},W:solpayloadsize'"'
     done >> /etc/conman.conf
     systemctl enable conman
     systemctl start conman
fi

#Update rsyslog
perl -pi -e "s/\\#\\\$ModLoad imudp/\\\$ModLoad imudp/" /etc/rsyslog.conf
perl -pi -e "s/\\#\\\$UDPServerRun 514/\\\$UDPServerRun 514/" /etc/rsyslog.conf
systemctl restart rsyslog
#echo "*.* @${sms_ip}:514" >> $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^cron/\\#cron/" $CHROOT/etc/rsyslog.conf
#perl -pi -e "s/^uucp/\\#uucp/" $CHROOT/etc/rsyslog.conf

#No Warewulf for now. These needs to be synced either via Nova or post boot
#wwsh file import /etc/passwd
#wwsh file import /etc/group
#wwsh file import /etc/shadow 
#wwsh file import /etc/slurm/slurm.conf
#wwsh file import /etc/pam.d/slurm
#wwsh file import /etc/munge/munge.key

if [[ ${enable_ipoib} -eq 1 ]];then
     cp /opt/intel/hpc-orchestrator/pub/examples/network/rhel/ifcfg-ib0.ww /tmp/
     #wwsh file import /tmp/ifcfg-ib0.ww
     #wwsh -y file set ifcfg-ib0.ww --path=/etc/sysconfig/network-scripts/ifcfg-ib0
fi

true
