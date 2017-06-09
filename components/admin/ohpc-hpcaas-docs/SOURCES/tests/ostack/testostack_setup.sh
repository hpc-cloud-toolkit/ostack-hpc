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

@test "[$testname] Verify OpenStack setup" {

    openstack endpoint list >& .ostack_output
    grep -q "nova.*compute" .ostack_output
    assert_success
    grep -q "neutron.*network" .ostack_output
    assert_success
    grep -q "keystone.*identity" .ostack_output
    assert_success
    grep -q "ironic.*baremetal" .ostack_output
    assert_success
    grep -q "nova.*compute" .ostack_output
    assert_success
    grep -q "Image Service.*image" .ostack_output
    assert_success
    rm -f .ostack_output

    openstack user list >& .ostack_output
    grep -q "admin" .ostack_output
    assert_success
    grep -q "ironic" .ostack_output
    assert_success
    grep -q "glance" .ostack_output
    assert_success
    grep -q "nova" .ostack_output
    assert_success
    grep -q "neutron" .ostack_output
    assert_success

    rm -f .ostack_output
}

@test "[$testname] Verify Neutron setup" {
}

@test "[$testname] Verify Glance and image setup" {
}

@test "[$testname] Verify OpenStack ironic enrollment" {
}

@test "[$testname] Verify OpenStack ironic enrollment" {
}

@test "[$testname] Verify heat template for hpc as service" {
# make sure that we have available baremetal nodes in nova as well as ironic
# check nova list with sms node name or IP
# check nova list with compute node name or IP
# if present then clean those nodes 
# instantiate node using heat template
# wait
# ping test
}
