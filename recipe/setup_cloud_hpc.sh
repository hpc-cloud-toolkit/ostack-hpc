#!/bin/bash
# -----------------------------------------------------------------------------------------
#  Example Installation Script Template
#  
#  This convenience script encapsulates command-line instructions highlighted in
#  the Install Guide that can be used as a starting point to perform a local
#  cluster install beginning with bare-metal. Necessary inputs that describe local
#  hardware characteristics, desired network settings, and other customizations
#  are controlled via a companion input file that is used to initialize variables 
#  within this script.
#   
#  Please see the Install Guide for more information regarding the
#  procedure. Note that the section numbering included in this script refers to
#  corresponding sections from the install guide.
# -----------------------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then echo "ERROR: Please run $0 as root"; exit 1; fi

set -E # traps on ERR will now be inherited by shell functions,
       # command substitution or subshells - equivalent to set -o errtrace

#For Debugging 
#set -x
SCRIPTDIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd -P && echo x)"
SCRIPTDIR="${SCRIPTDIR%x}"
cd $SCRIPTDIR

pwd

packstack_install=0
orchestrator_install=0
openhpc_install=0
USECASE=1

# enable common functions
source common_functions

usage () {
  echo "USAGE: $0 [-f] [-h] [-i=<input.local>] [-n=<cloud_node_inventory>]"
  echo " -u,--usecase       Select use case, 1 or 2"
  echo " -c,--openhpc       Install OpenHPC using the OpenHPC installation recipe"
  echo " -f,--forced        Forced run, run all sections with no prompt"
  echo " -h,--help          Print this message"
  echo " -i,--input         Location in local inputs"
  echo " -n,--inventory     Input to cloud HPC inventory file"
  echo " -o,--orchestrator  Install HPC Orchestrator using the HPC Orchestrator recipe"
  echo " -p,--packstack     Install OpenStack using the PackStack installation recipe"
}

for i in "$@"; do
  case $i in
    -c|--openhpc)
      openhpc_install=1
      shift # past argument with no value
    ;;
    -i=*|--input=*)
      if echo $i | grep '~'; then
        echo "ERROR: tilde(~) in pathname not supported."
        exit 3
      fi
      INPUT_LOCAL="${i#*=}"
      shift # past argument=value
    ;;
    -u=*|--usecase=*)
      export USECASE="${i#*=}"

      # Check if a valid use case
      if [[ $USECASE != "1" && $USECASE != "2" ]]; then
        echo "Unsupported usecase"
        exit 1
      fi
    ;;
    -f|--forced)
      FORCED=YES
      shift # past argument with no value
    ;;
    -n=*|--inventory=*)
      if echo $i | grep '~'; then
        echo "ERROR: tilde(~) in pathname not supported."
        exit 3
      fi
      CLOUD_HPC_INVENTORY="${i#*=}"
      shift # past argument with no value
    ;;
	-o|--orchestrator)
      orchestrator_install=1
      shift # past argument with no value
    ;;
	-p|--packstack)
      packstack_install=1
      shift # past argument with no value
    ;;
    -h|--help)
      usage
      exit 1
    ;;
    *)
      echo "ERROR: Unknown option \"$i\""
      usage
      exit 2
    ;;
  esac
done

# Check if a valid use case is selected
if [[ $USECASE != "1" && $USECASE != "2" ]]; then
  echo "Unsupported usecase, select a valid usecase [1,2]"
  exit 1
fi

inputFile=${INPUT_LOCAL}
cloudHpcInventory=${CLOUD_HPC_INVENTORY}

validateInputFile
validateHpcInventory

# -------------------------------- Begin Recipe -------------------------------------------
# Commands below are extracted from the install guide recipe and are intended for 
# execution on the master SMS host.
# -----------------------------------------------------------------------------------------

# Determine number of cloud computes and their hostnames
setup_computename

#Set the hostname of the machine
hostnamectl set-hostname ${sms_name}

#Install hpc orchestrator OR openhpc
if [ "${orchestrator_install}" -eq "1" ]; then
	mkdir -p /mnt/hpc_orch_iso
	mount -o loop ${orch_iso_path} /mnt/hpc_orch_iso
	rpm -Uvh /mnt/hpc_orch_iso/x86_64/Intel_HPC_Orchestrator_release-16.01.002.beta-8.1.x86_64.rpm
	rpm --import /etc/pki/pgp/HPC-Orchestrator*.asc
	pushd hpc_cent7/intel
	time source recipe.sh -f
	popd
fi

if [ "${openhpc_install}" -eq "1" ]; then
        export OHPC_INPUT_LOCAL=$(realpath ${INPUT_LOCAL})
        pushd hpc_cent7/ohpc
        time source recipe.sh
        popd
fi

#Run packstack install.
if [ "${packstack_install}" -eq "1" ]; then
	pushd ../packstack/recipe
	time source packstack-install.sh -s=${controller_ip} -f=${cc_subnet_cidr} -e=${sms_eth_internal}
	popd
fi

case $USECASE in
  1)
    time source set_os_hpc
  ;;
  2)
    pushd 2_CloudExtension
    time source set_os_hpc
    popd
  ;;
  *)
    echo "ERROR: Unsupported usecase"
    exit 1
  ;;
esac
    
true

#Call sinfo and srun to verify slurm's connection to the compute nodes
sinfo
srun -N ${num_ccomputes} hostname -i

# End
