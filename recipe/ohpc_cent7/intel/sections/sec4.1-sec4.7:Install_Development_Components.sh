#!/bin/bash
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Install Development Components (Section 4.1)-(Section 4.7)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

# ----------------------------------------------------------
# Install Development Components (Section 4.1)-(Section 4.7)
# ----------------------------------------------------------

yum -y groupinstall orch-autotools
#yum -y install valgrind-orch
yum -y install EasyBuild-orch
#yum -y install spack-orch
#yum -y install R_base-orch            

yum -y install gnu-compilers-orch intel-compilers-devel-orch

yum -y groupinstall orch-mpi
yum -y groupinstall orch-imb

#yum -y install papi-orch
#yum -y install intel-itac-orch
#yum -y install intel-vtune-orch
#yum -y install intel-advisor-orch
#yum -y install intel-inspector-orch
#yum -y groupinstall orch-mpiP
#yum -y groupinstall orch-tau

yum -y install lmod-defaults-intel-impi-orch

#yum -y groupinstall orch-adios        
#yum -y groupinstall orch-boost        
#yum -y groupinstall orch-fftw         
#yum -y groupinstall orch-gsl          
#yum -y groupinstall orch-hdf5         
#yum -y groupinstall orch-hypre        
#yum -y groupinstall orch-metis        
#yum -y groupinstall orch-mumps        
#yum -y groupinstall orch-netcdf       
#yum -y groupinstall orch-numpy        
#yum -y groupinstall orch-openblas     
#yum -y groupinstall orch-petsc        
#yum -y groupinstall orch-phdf5        
#yum -y groupinstall orch-scalapack    
#yum -y groupinstall orch-scipy        
#yum -y groupinstall orch-trilinos     

yum -y install testsuite-orch

echo "/opt/intel/hpc-orchestrator/pub/tests *(rw,no_subtree_check,fsid=12,no_root_squash)"
exportfs -a
#echo -n "${sms_ip}:/opt/intel/hpc-orchestrator/pub/tests " >> $CHROOT/etc/fstab
#echo "/opt/intel/hpc-orchestrator/pub/tests nfs nfsvers=3 0 0" >> $CHROOT/etc/fstab
#wwvnfs -y --chroot $CHROOT
#pdcp -g compute $CHROOT/etc/fstab /etc/fstab
# for Cloud this will be done in post cfg
#pdsh -g compute mount /opt/intel/hpc-orchestrator/pub/tests


true
