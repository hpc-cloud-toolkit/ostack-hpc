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
# enable common functions
source common_functions

usage () {
  echo "USAGE: $0 [-f] [-h] [-i=<input.local>] [-n=<cloud_node_inventory>]"
  echo " -f,--forced     Forced run, run all sections with no prompt"
  echo " -i,--input      Location in local inputs"
  echo " -n,--inventory  Input to cloud HPC inventory file"
  echo " -h,--help       Print this message"
}

for i in "$@"; do
  case $i in
    -i=*|--input=*)
      if echo $i | grep '~'; then
        echo "ERROR: tilde(~) in pathname not supported."
        exit 3
      fi
      INPUT_LOCAL="${i#*=}"
      shift # past argument=value
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

#set up hosts at head node or sms node
setup_hosts

# extend HPC to cloud
time source set_os_hpc

true

# End
