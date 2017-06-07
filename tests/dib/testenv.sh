#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1


testname="DIB"

#local environments
setup() {
dibelements=/usr/share/diskimage-builder/elements
#dibelements=../../dib/hpc/elements/
}

@test "[$testname] Verify diskimage-builder installation" {
    run rpm -q --queryformat='%{VERSION}\n' diskimage-builder
    assert_output "1.14.1"

    run which disk-image-create
    assert_success
}

@test "[$testname] Verify hpc elements installation" {
    # check of hpc elements in general
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep hpc /tmp/.f_output
    assert_success
}
@test "[$testname] Verify hpc elements hpc-env-base" {
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep hpc-env-base /tmp/.f_output
    assert_success
    assert_output "hpc-env-base"
}
@test "[$testname] Verify hpc elements hpc-mrsh" {
    #check for hpc-mrsh
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep "hpc-mrsh" /tmp/.f_output
    assert_success
    assert_output "hpc-mrsh"
}
@test "[$testname] Verify hpc elements hpc-slurm" {
    #check for hpc-slurm
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep "hpc-slurm" /tmp/.f_output
    assert_success
    assert_output "hpc-slurm"
}
@test "[$testname] Verify hpc elements hpc-dev-env" {
    #check for hpc-dev-env
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep "hpc-dev-env" /tmp/.f_output
    assert_success
    assert_output "hpc-dev-env"
}
@test "[$testname] Verify hpc elements hpc-dev-env" {
    #check for hpc-dev-env
    ls $dibelements|grep hpc > /tmp/.f_output
    run grep "hpc-dev-env" /tmp/.f_output
    assert_success
    assert_output "hpc-dev-env"
}

@test "[$testname] Verify cloud.cfg file is present" {

}
