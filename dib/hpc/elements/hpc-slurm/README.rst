============
hpc-slurm
============

Installs HPC slurm resource manager

Environment Variables
---------------------

DIB_HPC_BASE
  :Required: No
  :Default: OHPC
  :Description: name of the HPC package if it is from OpenHPC or Orchestrator, default is OpenHPC 
    for OpenHPC value is ohpc, this installs group ohpc-slurm-client
    for Orchestrator valid value is orch, this installs package orch-slurm-clien

DIB_HPC_IMAGE_TYPE
  :Required: no
  :Default: compute
  :Description: Tells diskimage builder type of image to be build, HPC sms node image or
    compute node image. some of the elements installs different binaries for sms node and 
    compute node. Valid values are
    compute: Builds image for HPC compute node.
    sms: Builds image for HPC sms nodei. Element installs slurmctld for sms node image.

.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::

