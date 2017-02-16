============
hpc-env-base
============

Installs base HPC environment and depenendencies
Installs pdsh, ntp, lmodorch and kernel

Environment Variables
---------------------

DIB_HPC_BASE
  :Required: No
  :Default: OHPC
  :Description: name of the HPC package if it is from OpenHPC or Orchestrator, default is OpenHPC 
    for OpenHPC it is OHPC, which installs package lmod-ohpc
    for Orchestrator it is orch, which installs package lmod-orch

DIB_HPC_IMAGE_TYPE
  :Required: no
  :Default: compute
  :Description: Tells diskimage builder type of image to be build, HPC sms node image or
    compute node image. Element installs different binaries for sms node and compute node. 
    Valid values are
    compute: Builds image for HPC compute node
    sms: Builds image for HPC sms node. 

.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::

