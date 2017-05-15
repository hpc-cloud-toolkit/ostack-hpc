#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1


testname="DIB"

@test "[$testname] Verify diskimage-builder installation" {
    run which disk-image-create
    assert_success

    run openstack --version
    assert_output "1.14.1"
}

@test "[$testname] Verify hpc elements installation" {
# verify if hpc elements are present as per the installation. TBD
}


