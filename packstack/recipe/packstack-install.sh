#!/bin/bash
#-------------------------------------------------------------------------------------------------
#This script installs OpenStack - mitaka release using the RDO installation (packstack) in
#conjunction with an answer file. It assumes that it is being run from a machine imaged with
#CentOS 7 operating system (minimal install or minimal with GNOME Desktop installed), has a 
#statically configured private IP address on one of the ethernet ports and has an answer.txt 
#file in the same directory as the calling process.
#
#This script requires 2 input parameters: sms_ip and flat_ip_range.
#sms_ip is the static local ip address that will be used for messaging to CNs
#nova_range is the IP range for flat DHCP for the Nova configuration.
#This script requires an 'answer.txt' answer file for PackStack in the current directory.
#-------------------------------------------------------------------------------------------------

#Read in the command line values
usage () {
    echo "USAGE: $0 --sms_ip=<sms_ip> --flat_ip_range=<flat_ip_range> --eth_interface=<ethernet interface>"
    echo "-s,--sms_ip           Local (internal) IP address on SMS"
    echo "-f,--flat_ip_range    IP range for flat DHCP for Nova Configuration"
    echo "-e,--eth_interface    IP range for flat DHCP for Nova Configuration"
    echo "-h,--help             Print this message"
}

if [ $# -eq 0 ]
then
    echo "Too few arguments"
    usage
    exit 1
elif [ $# -eq 1 ]
then
    if [ $1 == "-h" ] || [ $1 == "--help" ]
    then
        usage
        exit 0
    else
        echo "Too few arguments"
        usage
        exit 1
    fi
else
    for i in "$@"; do
        case $i in
            -s=*|--sms_ip=*)
                sms_ip="${i#*=}"
                shift
            ;;
			-e=*|--eth_interface=*)
				eth_interface="${i#*=}"
				shift
			;;
            -f=*|--flat_ip_range=*)
                flat_ip_range="${i#*=}"
                shift
            ;;
            -h|--help)
                usage
                exit 1
            ;;
            *)
                echo "ERROR: Unknown option \"$i\""
                usage
                exit 2
            ;;
        esac
    done
fi

#Disable firewall
systemctl disable firewalld
systemctl stop firewalld

#Disable NetworkManager
systemctl disable NetworkManager
systemctl stop NetworkManager

#Enable network
systemctl enable network
systemctl start network

# Packages required
yum -y install policycoreutils #httpd

#Install the RDO OpenStack Mitaka release yum repository. This is in the extras repository, which is enabled by default in CentOS 7
yum install -y centos-release-openstack-ocata

#Update the packages installed on the current machine. This step can take a while.
yum update -y

#Install PacksStack
yum install -y openstack-packstack

#Edit answer file with parameters passed in from command line
sed --in-place "s|<sms_ip>|${sms_ip}|" ocata_answer
sed --in-place "s|<flat_ip_range>|${flat_ip_range}|" ocata_answer
sed --in-place "s|<eth_interface>|${eth_interface}|" ocata_answer

#Install OpenStack using PackStack according to the answer file in answer.txt This step can take a while.
setenforce 0
#exit
#before installing openstack, increase the limits
source tune_controller.sh
packstack --answer-file=ocata_answer

# Now update the number of connections for db.
sed -in-place  "s|^max_connections.*|max_connection = 100000|" /etc/my.cnf.d/server.cnf
systemctl restart mariadb

#Rename the default apache configuration file to enable the web portal login (horizon).
mv /etc/httpd/conf.d/15-default.conf /etc/httpd/conf.d/15-default.conf.old
systemctl restart httpd
