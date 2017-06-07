#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions || exit 1
source ../common/functions || exit 1

if [ -s ../TEST_ENV ];then
    source ../TEST_ENV
fi

testname="ostack"
# for testing we are installing packstack, and assuming keystonerc_admin is present at /root
source /root/keystonerc_admin || exit 1
#rpm=conman${DELIM}

@test "[$testname] Verify pack installation" {
    run rpm -q --queryformat='%{VERSION}\n' openstack-packstack
    assert_output "8.0.2"
}

@test "[$testname] Verify man page availability" {
    run man -w openstack
    assert_success
    assert_output "/usr/share/man/man1/openstack.1.gz"
}

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
    assert_output "openstack 2.3.0"
}



