============
hpc-opa
============

Installs Intel Omni-Path Fabric Software

Environment Variables
---------------------

DIB_HPC_IMAGE_TYPE
  :Required: yes
  :Default: compute
  :Description: Tells diskimage builder type of image to be build, HPC sms node image or
    compute node image. Element installs different binaries for sms node and compute node.
    Valid values are
    compute: Builds image for HPC compute node
    sms: Builds image for HPC sms node.

DIB_HPC_OPA_PKG
  :Required: yes
  :Default:
  :Description: Tells diskimage builder from where to get Intel OPA installation package.

.. note::
    This element only tested on CentOS7
