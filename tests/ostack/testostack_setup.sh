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

@test "[$testname] Verify OpenStack enrollment" {
}
@test "[OOB] ipmitool exists" {
    run which ipmitool
    assert_success
}

@test "[OOB] istat exists" {
    run which istat
    assert_success
}

@test "[OOB] ipmitool local bmc ping" {

    # Check 4 channels of ipmi lan for IP address

    for lan in `seq 1 4`; do
        ipmitool lan print $lan > .cmd_output || flunk "Unable to run ipmitool"
        local my_bmc_ip=`cat .cmd_output | grep "IP Address              :" | awk '{print $4}'`

        if [ $? -ne 0 ];then
            flunk "Unable to ascertain local BMC IP address"
        fi

        if [ "$my_bmc_ip" != "0.0.0.0" ];then
            break
        fi
    done

    run ping -c 1 -W 1 -q $my_bmc_ip
    assert_success
}

@test "[OOB] ipmitool power status" {

    if [ -z "$IPMI_PASSWORD" ];then
        flunk "IPMI_PASSWORD is not set"
    fi

    # Check 4 channels of ipmi lan for IP address

    for lan in `seq 1 4`; do
        ipmitool lan print $lan > .cmd_output || flunk "Unable to run ipmitool"
        local my_bmc_ip=`cat .cmd_output | grep "IP Address              :" | awk '{print $4}'`
        
        if [ $? -ne 0 ];then
            flunk "Unable to ascertain local BMC IP address"
        fi
        
        if [ "$my_bmc_ip" != "0.0.0.0" ];then
            break
        fi
    done

    # verify power status locally
    run istat $my_bmc_ip
    assert_output "$my_bmc_ip Chassis Power is on"
}

@test "[OOB] ipmitool read CPU1 sensor data" {

    if [ -z "$IPMI_PASSWORD" ];then
        flunk "IPMI_PASSWORD is not set"
    fi

    # Check 4 channels of ipmi lan for IP address

    for lan in `seq 1 4`; do
        ipmitool lan print $lan > .cmd_output || flunk "Unable to run ipmitool"
        local my_bmc_ip=`cat .cmd_output | grep "IP Address              :" | awk '{print $4}'`
        
        if [ $? -ne 0 ];then
            flunk "Unable to ascertain local BMC IP address"
        fi
        
        if [ "$my_bmc_ip" != "0.0.0.0" ];then
            break
        fi
    done
    
    # read sensor data locally
    ipmitool -E -I lanplus -H $my_bmc_ip -U root sensor > .cmd_output || flunk "Unable to query sensor data"
    egrep -q "CPU1 Temp|P1 Therm Margin" .cmd_output   || flunk "CPU1 Temp not found in sensor data"

}

@test "[OOB] ipmitool read sel log" {
    skip "skipp sel log read as entry 1 may not always be available"

    if [ -z "$IPMI_PASSWORD" ];then
        flunk "IPMI_PASSWORD is not set"
    fi
    
    # Check 4 channels of ipmi lan for IP address

    for lan in `seq 1 4`; do
        ipmitool lan print $lan > .cmd_output || flunk "Unable to run ipmitool"
        local my_bmc_ip=`cat .cmd_output | grep "IP Address              :" | awk '{print $4}'`
        
        if [ $? -ne 0 ];then
            flunk "Unable to ascertain local BMC IP address"
        fi

        if [ "$my_bmc_ip" != "0.0.0.0" ];then
            break
        fi
    done
    
    # verify sel log availability (query 1st record)
    run timeout 10s ipmitool -E -I lanplus -H $my_bmc_ip -U root sel get 1
    assert_success

    rm -f .cmd_output
}

