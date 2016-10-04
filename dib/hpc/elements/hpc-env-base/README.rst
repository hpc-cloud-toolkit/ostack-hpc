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

.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::
   export DIB_YUM_REPO_CONF=/etc/yum.repos.d/HPC_Orchestrator.repo


