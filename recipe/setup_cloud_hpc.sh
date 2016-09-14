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
set -x
SCRIPTDIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd -P && echo x)"
SCRIPTDIR="${SCRIPTDIR%x}"
cd $SCRIPTDIR

pwd
# enable common functions
source setup_hosts

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

if [[ -z "${inputFile}" || ! -e "${inputFile}" ]];then
  echo "Error: Unable to access local input file -> \"${inputFile}\""
  exit 1
else
  . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
fi
if [[ -z "${cloudHpcInventory}" || ! -e "${cloudHpcInventory}" ]];then
  echo "Error: Unable to access Cloud hpc inventory file -> \"${cloudHpcInventory}\""
  exit 1
else
  . ${cloudHpcInventory} || { echo "Error sourcing ${cloudHpcInventory}"; exit 1; }
fi

_BADCOUNT=0

for((i=0; i<${#c_ip[@]}; i++)) ; do
  if ! [[ ${c_ip[i]} =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([\
                            0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "ERROR: Invalid IP address #$i: ${c_ip[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
  if ! [[ ${c_bmc[i]} =~ ^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([\
                             0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    echo "ERROR: Invalid BMC IP address #$i: ${c_bmc[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
  if ! [[ `echo ${c_mac[i]^^} | egrep "^([0-9A-F]{2}:){5}[0-9A-F]{2}$"` ]]; then
    echo "ERROR: Invalid MAC address #$i: ${c_mac[i]}"
    _BADCOUNT=$((_BADCOUNT+1))
  fi
done

[[ $_BADCOUNT -eq 0 ]] || exit 3

# -------------------------------- Begin Recipe -------------------------------------------
# Commands below are extracted from the install guide recipe and are intended for 
# execution on the master SMS host.
# -----------------------------------------------------------------------------------------


# Determine number of computes and their hostnames
export num_computes=${num_computes:-${#cc_ip[@]}}
for((i=0; i<${num_computes}; i++)) ; do
   cc_name[$i]=${nodename_prefix}$((i+1))
done
export c_name

#set up hosts at head node or sms node
setup_hosts

true

# End
