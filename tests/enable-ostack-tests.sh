#!/bin/bash
# HPC in cloud tests are derived from OpenHPC Tests. Not all OpenHPC tests are applicable
# for HPC in cloud. This script will enable tests only applicable for HPC in cloud

# Please verify these parametes
TESTSUITE_DIR=${TESTSUITE_DIR:-/home/ohpc-test/tests}
TESTSUITE_USER=${TESTSUITE_USER:-ohcp-test}
BACKUP_DIR=$TESTSUITE_DIR/backup
# OpenHPC tests can be enabled disabled either by command line or by having
# its own configure.ac & Makefile.am files. We decided to have second option
# which allows seemless enablement of tests
 
# create a backup folder in case someone wants to revert the changes
function enable_tests {
   if [[ ! -e $BACKUP_DIR ]]; then
       mkdir -p $BACKUP_DIR
   fi
   
   if [[  -f "$TESTSUITE_DIR/Makefile.am.ostack" ]]; then
       if [[  -f "$TESTSUITE_DIR/Makefile.am" ]]; then
           mv $TESTSUITE_DIR/Makefile.am $BACKUP_DIR/Makefile.am
       fi
       cp $TESTSUITE_DIR/Makefile.am.ostack $TESTSUITE_DIR/Makefile.am
   fi
   if [[  -f "$TESTSUITE_DIR/configure.ac.ostack" ]]; then
       if [[  -f "$TESTSUITE_DIR/configure.ac" ]]; then
           mv $TESTSUITE_DIR/configure.ac $BACKUP_DIR/configure.ac
       fi
       cp $TESTSUITE_DIR/configure.ac.ostack $TESTSUITE_DIR/configure.ac
   fi
   if [[  -f "$TESTSUITE_DIR/admin/Makefile.am.ostack" ]]; then
       if [[  -f "$TESTSUITE_DIR/admin/Makefile.am" ]]; then
           if [[ ! -e $BACKUP_DIR/admin ]]; then
               mkdir -p $BACKUP_DIR/admin
           fi
           mv $TESTSUITE_DIR/admin/Makefile.am $BACKUP_DIR/admin/Makefile.am
       fi
       cp $TESTSUITE_DIR/admin/Makefile.am.ostack $TESTSUITE_DIR/admin/Makefile.am
   fi
   if [[  -f "$TESTSUITE_DIR/user-env/Makefile.am.ostack" ]]; then
       if [[  -f "$TESTSUITE_DIR/user-env/Makefile.am" ]]; then
           if [[ ! -e $BACKUP_DIR/user-env ]]; then
               mkdir -p $BACKUP_DIR/user-env
           fi
           mv $TESTSUITE_DIR/user-env/Makefile.am $BACKUP_DIR/user-env/Makefile.am
       fi
       cp $TESTSUITE_DIR/user-env/Makefile.am.ostack $TESTSUITE_DIR/user-env/Makefile.am
   fi
}

function restore_orig {
    if [[  -f "$BACKUP_DIR/Makefile.am" ]]; then
        mv $BACKUP_DIR/Makefile.am $TESTSUITE_DIR/Makefile.am
    fi
    if [[  -f "$BACKUP_DIR/configure.ac" ]]; then
        mv $BACKUP_DIR/configure.ac $TESTSUITE_DIR/configure.ac
    fi
    if [[  -f "$BACKUP_DIR/admin/Makefile.am" ]]; then
        mv $BACKUP_DIR/admin/Makefile.am $TESTSUITE_DIR/admin/Makefile.am
    fi
    if [[  -f "$BACKUP_DIR/user-env/Makefile.am" ]]; then
        mv $BACKUP_DIR/user-env/Makefile.am $TESTSUITE_DIR/user-env/Makefile.am
    fi
}

USAGE () {
    echo " "
    echo "Usage: enable-ostack-tests [-e|-r]"
    echo "       enable ostack cloud hpc tests and restores back original ohpc test"
    echo " "
    echo "   -e,--enable        Enables cloud hpc tests"
    echo "   -r,--restore       Restores original ohpc tests"
    echo " "
    exit 0
}

################
# get options
#set -x
for i in "$@"; do
  case $i in
    -e|--enable)
      echo "Enabling HPC cloud tests"
      enable_tests
      exit 0
      shift # past argument with no value
    ;;
    -r=*|--restore=*)
        echo "restoring OpenHPC original tests"
        exit 0
        shift # past argument with no value
    ;;
    -h|--help)
      USAGE
      exit 1
    ;;
    *)
     echo "enable/restore functions are active"
    ;;
  esac
done
