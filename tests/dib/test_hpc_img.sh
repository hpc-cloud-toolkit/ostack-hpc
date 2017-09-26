#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1

if [ -s ../TEST_ENV ];then
    source ../TEST_ENV
fi

testname="DIB"

setup() {
   deployfile=ironic_deploy 
   smsimage=sms_image 
   cnimage=cn_image 
}
teardown() {
   #Remove unwanted files which was generated as a part of this test
   rm -fr $deployfile*
   rm -fr $smsimage*
   rm -fr $cnimage*
}
@test "[$testname] Verify Head node image creation" {
    #enable local disk-image-builder
	export DIB_DEV_USER_USERNAME=chpc
	export DIB_DEV_USER_PASSWORD=intel8086
	export DIB_DEV_USER_PWDLESS_SUDO=1
	export DIB_DEBUG_TRACE=1
	export ELEMENTS_PATH=/opt/ohpc/admin/dib-chpc/elements/
	export DIB_HPC_BASE=ohpc
	export DIB_HPC_FILE_PATH=/opt/ohpc/admin/dib-chpc/hpc-files

	# tell to build sms node image
	export DIB_HPC_IMAGE_TYPE=sms
	# temp path for ssh authorized keys
	export DIB_HPC_SSH_PUB_KEY=/root/.ssh/hpcasservice
	export DIB_NTP_SERVER=10.23.184.104

	# sms node specific variables, mainly used by hpc-dev-env elements
	# compiler
	export DIB_HPC_COMPILER="gnu"
	#MPI lib to install
	export DIB_HPC_MPI="openmpi mvapich2"
	# Performance tools
	export DIB_HPC_PERF_TOOLS="perf-tools"
	# 3rd Part Libraries & Tools
	export DIB_HPC_3RD_LIBS="serial-libs parallel-libs io-libs python-libs runtimes"

	export DIB_HPC_OHPC_PKG="https://github.com/openhpc/ohpc/releases/download/v1.2.1.GA/ohpc-release-centos7.2-1.2-1.x86_64.rpm"

	disk-image-create centos7 vm local-config dhcp-all-interfaces devuser hpc-env-base hpc-mrsh hpc-slurm hpc-dev-env -o $smsimage

        #Now verify if we were able to create image
        run test -f ./$smsimage.qcow2
        assert_success
}
@test "[$testname] Verify Compute node image creation" {
	#enable local disk-image-builder
	#export PATH=/home/ppk/dib/dev/diskimage-builder/bin:/home/ppk/dib/dev/dib-utils/bin:$PATH
	export DIB_DEV_USER_USERNAME=chpc
	export DIB_DEV_USER_PASSWORD=chpc123
	export DIB_DEV_USER_PWDLESS_SUDO=1
	export DIB_DEBUG_TRACE=1
	export ELEMENTS_PATH=/opt/ohpc/admin/dib-chpc/elements/
	export DIB_HPC_BASE=ohpc
	export DIB_HPC_FILE_PATH=/opt/ohpc/admin/dib-chpc/hpc-files
	# path of ssh authorized keys for ssh access
	export DIB_HPC_SSH_PUB_KEY=/root/.ssh/hpcasservice
	export DIB_NTP_SERVER=10.23.184.104

	# tell to build sms node image
	export DIB_HPC_IMAGE_TYPE=compute

	export DIB_HPC_OHPC_PKG="https://github.com/openhpc/ohpc/releases/download/v1.2.1.GA/ohpc-release-centos7.2-1.2-1.x86_64.rpm"

	disk-image-create centos7 vm local-config dhcp-all-interfaces devuser hpc-env-base hpc-mrsh hpc-slurm -o $cnimage
        #Now verify if we were able to create image
        run test -f ./$cnimage.qcow2
        assert_success
}

@test "[$testname] Verify deploy image creation" {
    # Create deploy image and test
    export DIB_REPOREF_ironic_agent=stable/mitaka
    disk-image-create ironic-agent centos7 -o $deployfile
    # now check if file is generated
    run test -f ./$deployfile.kernel
    assert_success
    run test -f ./$deployfile.vnlinuz
    assert_success
    run test -f ./$deployfile.initramfs
    assert_success
}

