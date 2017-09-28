# ostack-hpc

### Introduction
This project enables HPC environment in an OpenStack cloud. It takes ingredients from [OpenHPC](http://openhpc.community) and combines with OpenStack automation to create HPC environment. This assumes that you have an existing OpenStack cloud infrastructure. For testing purpose, you can use packstack from red hat distribution. Directory packstack includes sample answer file for OpenStack ocata release, along with sample script to install OpenStack using packstack. 

Below are the two main use cases:
##### HPC as a Service
In this case, an independent HPC environment is created within an OpenStack cloud. This includes the creation of an HPC head node and HPC compute nodes.
##### HPC Cloud Burst
In this case existing HPC system (OpenHPC based) is extended with additional resource from OpenStack cloud. Same HPC resource manager can launch a jobs on cloud computes.

### Mailing List
* **hpc-cloud-toolkit-users** ([Subscribe/Unsubscribe](https://groups.io/g/hpc-cloud-toolkit-users)): 
Intended for general questions, discussions, a suggestion to the project by users.
* **hpc-cloud-toolkit-devel** ([Subscribe/Unsubscribe](https://groups.io/g/hpc-cloud-toolkit-devel)): 
Intended for developers contributing the hpc-cloud-toolkit. 


### Getting Started
The best place to start with reading User guide [OHPC-HPCaaS-Install_guide0.7.pdf](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases/download/v0.7/OHPC-HPCaaS-Install_guide0.7.pdf) and trying out the recipe on your OpenStack cloud. This guide along with auto-generated recipe is installed via [docs-chpc-0.1-66.1.x86_64.rpm](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases/download/v0.7/docs-chpc-0.1-66.1.x86_64.rpm) at location "/opt/ohpc/pub/doc/recipes/centos7/x86_64/openstack/slurm/". 
If you are interested in browsing source than recommend reading "README" located in almost an every directory to guide you through the code organization.

### Release v0.7
This is the first preview release of hpc_cloud_toolkit ([Release v0.7](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases))
Facts:
* Tested OS: Centos 7.3
* OpenStack version: OpenStack Ocata
* OpenHPC version: 1.3.1

Available packages for centos Installation:

* [dib-chpc](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases/download/v0.7/dib-chpc-0.1-24.1.x86_64.rpm): Installs HPC specific element to build HPC images, requires diskimage-builder.
* [docs-chpc](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases/download/v0.7/docs-chpc-0.1-66.1.x86_64.rpm): Installs an auto-generated recipe and documentation, describing how to instantiate HPC in an OpenStack Cloud. Installed location "/opt/ohpc/pub/doc/recipes/centos7/x86_64/openstack/slurm/" 
* [test-suite-chpc](https://github.com/hpc-cloud-toolkit/ostack-hpc/releases/download/v0.7/test-suite-chpc-0.1-31.1.noarch.rpm): Installs integration tests, specific to HPC in OpenStack Cloud. Requires OpenHPC test suite to be installed to run all hpc tests.
