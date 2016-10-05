#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Enable required repositories (Section 3.1)-(Section 3.2)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

# --------------------------------------------------------
# Enable required repositories (Section 3.1)-(Section 3.2)
# --------------------------------------------------------


# Verify local repository has been enabled before proceeding

echo "This checks if the ISO file mounted at /mnt/hpc_orch_iso is enabled as a local repo" 
yum repolist | grep -q Orchestrator
if [ $? -ne 0 ];then
   echo "Error: Mounted local repository is not enabled"
   echo "Error: Check that /mnt/hpc_orch_iso or /etc/yum.repos.d/HPC_Orchestrator.repo are installed properly"
   exit 1
fi


true
