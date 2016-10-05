#!/bin/bash

echo "installing ohpc rpm"
yum -y install https://github.com/openhpc/ohpc/releases/download/v1.1.GA/ohpc-release-centos7.2-1.1-1.x86_64.rpm

echo "ohpc installed" > /tmp/ohpc.log


