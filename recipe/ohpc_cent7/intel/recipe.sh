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

SCRIPTDIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd -P && echo x)"
SCRIPTDIR="${SCRIPTDIR%x}"
cd $SCRIPTDIR

pwd

SECTIONNUM=0
SECTIONNAME[$SECTIONNUM]="$0"

# this syntax needed to -1+1 doesn't have an RC of 1
CountErrorTrap() { SECTIONERR[$SECTIONNUM]=$((++SECTIONERR[$SECTIONNUM])); }
ReportExitTrap() {
  echo -e "\nError count by section:"
  for I in ${!SECTIONNAME[@]}; do
    printf "%-72s : %d\n" "${SECTIONNAME[$I]}" ${SECTIONERR[$I]}
  done
}

trap CountErrorTrap ERR
trap ReportExitTrap EXIT

askrun () {
  SECTIONNUM=${#SECTIONNAME[@]}
  SECTIONNAME[$SECTIONNUM]="$2"
  SECTIONERR[$SECTIONNUM]=0

  while [ -z "$FORCED" ]; do
    read -p "Run \"$2\", Yes/Abort? [(y),a]: " answer
    case ${answer:0:1} in
      ""|y|Y )
        break
      ;;
      a|A )
        echo -e "Aborting $0\n"
        exit 1
      ;;
    esac
  done

  time source $1
  if [ $? -ne 0 ]; then
    echo    "###############################"
    echo    "## Section Execution Failure ##"
    echo    "###############################\n"
    echo -e "Aborting $0\n"
    exit 1
  fi
  echo -ne "$3"

  # we're back to meta script errors
  SECTIONNUM=0
}

usage () {
  echo "USAGE: $0 [-f] [-h] [-i=<input.local>]"
  echo " -f,--forced     Forced run, run all sections with no prompt"
  echo " -i,--input      Location in local inputs"
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

if [[ -z "${inputFile}" || ! -e "${inputFile}" ]];then
  echo "Error: Unable to access local input file -> \"${inputFile}\""
  exit 1
else
  . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
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
export num_computes=${num_computes:-${#c_ip[@]}}
for((i=0; i<${num_computes}; i++)) ; do
   c_name[$i]=${nodename_prefix}$((i+1))
done
export c_name



true
# Enable required repositories (Section 3.1)-(Section 3.2)
askrun "./sections/sec3.1-sec3.2:Enable_required_repositories.sh" \
  "Enable required repositories (Section 3.1)-(Section 3.2)" "\n\n"
cd $SCRIPTDIR

# Initial HeadNode configuration (Section 3.4)-(Section 3.7)
askrun "./sections/sec3.4-sec3.7:Initial_HeadNode_configuration.sh" \
  "Initial HeadNode configuration (Section 3.4)-(Section 3.7)" "\n\n"
cd $SCRIPTDIR

# Define compute image for provisioning (Section 3.8)-(Section 3.8.3)
askrun "./sections/sec3.8-sec3.8.3:Define_compute_image_for_provisioning.sh" \
  "Define compute image for provisioning (Section 3.8)-(Section 3.8.3)" "\n\n"
cd $SCRIPTDIR

# Additional Customizations (optional) (Section 3.8.4)-(Section 3.8.4.11)
askrun "./sections/sec3.8.4-sec3.8.4.11:Additional_Customizations_-optional-.sh" \
  "Additional Customizations (optional) (Section 3.8.4)-(Section 3.8.4.11)" "\n\n"
cd $SCRIPTDIR

# Finalize Provisioning (Section 3.9)-(Section 3.10)
askrun "./sections/sec3.9-sec3.10:Finalize_Provisioning.sh" \
  "Finalize Provisioning (Section 3.9)-(Section 3.10)" "\n\n"
cd $SCRIPTDIR

# Install Development Components (Section 4.1)-(Section 4.7)
askrun "./sections/sec4.1-sec4.7:Install_Development_Components.sh" \
  "Install Development Components (Section 4.1)-(Section 4.7)" "\n\n"
cd $SCRIPTDIR

# Resource Manager Startup (Section 5)-(Section 6)
askrun "./sections/sec5-sec6:Resource_Manager_Startup.sh" \
  "Resource Manager Startup (Section 5)-(Section 6)" "\n\n"
cd $SCRIPTDIR

# CLCK Supportability Extensions (Section 7)
askrun "./sections/sec7:CLCK_Supportability_Extensions.sh" \
  "CLCK Supportability Extensions (Section 7)" "\n\n"
cd $SCRIPTDIR

#Workaround for bad install orchestrator
echo "Workaround for section 4 installation bug of orchestrator install"
time source orch_bug_wr
# End
