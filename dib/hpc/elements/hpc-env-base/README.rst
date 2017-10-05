============
hpc-env-base
============

Installs base HPC environment and dependencies
Installs pdsh, ntp, lmod and kernel

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

DIB_HPC_SSH_PUB_KEY
  :Required: no
  :Default: /home/.ssh/
  :Description: for sms node it will generate keys and copy authorized keys to this 
    path DIB_HPC_SSH_PUB_KEY for compute node, it copies autorized_keys from 
    DIB_HPC_SSH_PUB_KEY, and copy to /root/.ssh/ 

DIB_HPC_FILE_PATH
  :Required: yes
  :Default: none
  :Description: This path maintains hpc environment specific files cloud.cfg and
    hpc-env-in-cloud.sh. It copies these files to images. Without these files
    hpc workload might not work as expected. 

.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::
   export DIB_YUM_REPO_CONF=/etc/yum.repos.d/HPC_Orchestrator.repo


