#!/bin/bash
# This file performs tuning for Openstack performance and stability
# Increase ulimit
echo "* soft nofile 102400" >> /etc/security/limits.conf
echo "* hard nofile 102400" >> /etc/security/limits.conf
echo "* soft noproc 102400" >> /etc/security/limits.conf
echo "* hard noproc 102400" >> /etc/security/limits.conf

echo "* soft nofile 102400" >> /etc/security/limits.d/90-nproc.conf
echo "* hard nofile 102400" >> /etc/security/limits.d/90-nproc.conf
echo "* soft noproc 102400" >> /etc/security/limits.d/90-nproc.conf
echo "* hard noproc 102400" >> /etc/security/limits.d/90-nproc.conf
echo "root soft nproc unlimited" >> /etc/security/limits.d/90-nproc.conf

#Increase limits for mariadb
mkdir -p /etc/systemd/system/mariadb.service.d/
cp mariadb_limits.conf /etc/systemd/system/mariadb.service.d/limits.conf
systemctl daemon-reload

