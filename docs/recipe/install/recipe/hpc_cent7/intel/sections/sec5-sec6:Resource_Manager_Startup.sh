
## FILE: hpc_cent7/intel/sections/sec5-sec6:Resource_Manager_Startup.sh
#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Resource Manager Startup (Section 5)-(Section 6)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
# ------------------------------------------------
# Resource Manager Startup (Section 5)-(Section 6)
# ------------------------------------------------
systemctl enable munge
systemctl enable slurmctld
systemctl start munge
systemctl start slurmctld
# Here we need to run Postboot script on Cloud Compute nodes
#pdsh -w ${nodename_prefix}[1-${num_computes}] systemctl enable munge
#pdsh -w ${nodename_prefix}[1-${num_computes}] systemctl start munge
#pdsh -w ${nodename_prefix}[1-${num_computes}] systemctl enable slurmd
#pdsh -w ${nodename_prefix}[1-${num_computes}] systemctl start slurmd
# for Demo all the nodes are from Cloud so this needs to be called once nodes are added and slurm is started on nodes.
#scontrol update nodename=${nodename_prefix}[1-${num_computes}] state=idle
useradd -U -m test
chown -R test:test ~test
#wwsh file resync passwd shadow group
# Wait for WW to recalc checksums on synced files
sleep 5
#pdsh -w ${nodename_prefix}[1-${num_computes}] /warewulf/bin/wwgetfiles 
true
#  
