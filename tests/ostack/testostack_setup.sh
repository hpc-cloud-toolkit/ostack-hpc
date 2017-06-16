#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1

if [ -s ../TEST_ENV ];then
    source ../TEST_ENV
fi

testname="ostack"
# for testing we are installing packstack, and assuming keystonerc_admin is present at /root
setup() {
   source /root/keystonerc_admin
   netname=sharednet1
    
}
teardown() {
   #Remove unwanted files which was generated as a part of this test
}

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
    #verify if neutron is setup for flat network.
    neutron net-show $netname  > /tmp/.output
    neutron net-show sharednet1|grep provider:network_type|awk {'print $4'} > tmp/.output
    run grep flat /tmp/.output
    assert_success
    assert_output "flat"
}

@test "[$testname] Verify Glance and image setup" {
}

@test "[$testname] Verify OpenStack ironic enrollment" {
}

@test "[$testname] Verify OpenStack nova flavor matches with ironic nodes charaterisitcs" {
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
