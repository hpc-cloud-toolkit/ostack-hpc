============
hpc-env-base
============

Installs hpc development environments, tools and 3rd party library for head node functionality

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
    compute node image. some of the elements installs different binaries for sms node and 
    compute node. Valid values are
    compute: Builds image for HPC compute node
    sms: Builds image for HPC sms node
   
DIB_HPC_COMPILER
  :Required: yes
  :Default: gnu
  :Description: Compilers to be installed on image, default is gnu, other possible 
    compiler is intel or cominication of both "intel gnu"

DIB_HPC_MPI
  :Required: yes
  :Default: openmpi and mvapich2
  :Description: MPI run time lbraries, which will be installed on image
    default is openmpi and mvapich2, other option can be impi or combination
    of all three "mvapich2, impi, openmpi"

DIB_HPC_PERFTOOLS
  :Required: no
  :Default: perf-tools
  :Description: HPC performance tools, to be installed on image

DIB_HPC_3RD_LIBS
  :Required: no
  :Default: serial-libs parallel-libs io-libs python-libs runtimes
  :Description: 3rd party libraries which needs to be installed on image.


.. note::
    This element only tested on CentOS7

Put `OpenHPC.repo` or `hpcorch.repo` into `/etc/yum.repos.d/`::

