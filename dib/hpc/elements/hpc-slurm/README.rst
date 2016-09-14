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

.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::

