#!../common/bats/bin/bats
# -*-sh-*-

load ../common/test_helper_functions
source ../common/functions || exit 1

if [ -s ../TEST_ENV ];then
    source ../TEST_ENV
fi

testname="DIB"

@test "[$testname] Verify Head node image creation" {

}
@test "[$testname] Verify Compute node image creation" {

}
@test "[$testname] Verify deploy image creation" {

}

