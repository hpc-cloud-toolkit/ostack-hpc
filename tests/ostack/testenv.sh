#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1

if [ -s ../TEST_ENV ];then
    source ../TEST_ENV
fi

testname="ostack"
# for testing we are installing packstack, and assuming keystonerc_admin is present at /root
source /root/keystonerc_admin
#rpm=conman${DELIM}

@test "[$testname] Verify openstack installation" {
    run which openstack
    assert_success

    run which keystone
    assert_success

    run which glance
    assert_success

    run which nova
    assert_success

    run which ironic
    assert_success

    run which neutron
    assert_success

    run which heat
    assert_success

    run openstack --version
    assert_success
}

@test "[$testname] Verify man page availability" {
    run man -w openstack
    assert_success
    assert_output "/usr/share/man/man1/openstack.1.gz"
}


