#!/bin/bash
#Get the current allotted IP matching 192 series...
currip=$(ifconfig | grep inet | awk '{print $2}' | grep 192*)
currhost=$(hostname)
#Add proxies to /etc/environment
echo "export http_proxy=proxy.ra.intel.com:911" >> /etc/environment
echo "export https_proxy=proxy.ra.intel.com:911" >> /etc/environment

# lOCAL no proxies for Headnode, intel.com
echo "export no_proxy=.intel.com,$currip" >> /etc/environment
source /etc/environment

#update hosts file right ip addresses
perl -pi -e "s/^(.*)$currhost/$currip $currhost/g" /etc/hosts

# add root in /etc/security/access.conf
echo "+:root : $currip " >> /etc/security/access.conf

# setup ssh keys do that root can ssh locally on that system
ssh-keygen -f /root/.ssh/cluster -N ""
cat /root/.ssh/cluster.pub >> /root/.ssh/authorized_keys 
scp /home_nfs/guptarav/hpc_preq/CentOS* /etc/yum.repos.d/
yum clean all
yum repolist
yum update -y

#update ohpc-docs info here
rpm -ivh https://github.com/openhpc/ohpc/releases/download/v1.3.GA/ohpc-release-1.3-1.el7.x86_64.rpm
 
#update input.local
# update cloud inventory file


# update answers.txt
perl -pie "s/^CONFIG_CONTROLLER_HOST=(.+)/CONFIG_CONTROLLER_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_COMPUTE_HOSTS=(.+)/CONFIG_COMPUTE_HOSTS=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_NETWORK_HOSTS=(.+)/CONFIG_NETWORK_HOSTS=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_STORAGE_HOST=(.+)/CONFIG_STORAGE_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_SAHARA_HOST=(.+)/CONFIG_SAHARA_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_AMQP_HOST=(.+)/CONFIG_AMQP_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_MARIADB_HOST=(.+)/CONFIG_MARIADB_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_MONGODB_HOST=(.+)/CONFIG_MONGODB_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_REDIS_MASTER_HOST=(.+)/CONFIG_REDIS_MASTER_HOST=$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt
perl -pie "s/^CONFIG_KEYSTONE_LDAP_URL=ldap\:\/\/(.+)/CONFIG_KEYSTONE_LDAP_URL=ldap\:\/\/$currip/" /home_nfs/guptarav/hpc/packstack/recipe/answer.txt

#update answer.txt with correct ips
cat /root/cmt_ohpc_inputs | grep "c_ip\[3\]" | awk '{split($0,numbers,"="); print numbers[2]}'


