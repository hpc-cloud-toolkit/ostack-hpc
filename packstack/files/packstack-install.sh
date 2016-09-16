#!/usr/bin/bash
# THIS IS FOR CENTOS7 INSTALLATION

# Disable firewall
systemctl disable firewalld
systemctl stop firewalld

# Disable network manager
systemctl disable NetworkManager
systemctl stop NetworkManager

# Enable networking
systemctl enable network
systemctl start network

# On CentOS, the Extras repository provides the RPM that enables the OpenStack
# repository. Extras is enabled by default on CentOS 7, so you can simply
# install the RPM to set up the OpenStack repository.
yum install -y centos-release-openstack-mitaka

# Update your current packages
yum update -y

# Install Packstack Installer
yum install -y openstack-packstack

# Run Packstack to install OpenStack
# For a single node OpenStack deployment, run the following command:
# packstack --allinone
#
# If you have run Packstack previously, there will be a file in your home
# directory named something like packstack-answers-yyyymmdd-nnnnnn.txt
# You will probably want to use that file again, using the --answer-file option
#
# packstack --answer-file=/path/to/answer.file