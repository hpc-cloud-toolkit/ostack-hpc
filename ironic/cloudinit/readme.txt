# PREMITIVE README, TO BE REVISED

nova boot --user-data cloudinit/userdata.yml \
--flavor my-baremetal-flavor --key-name ironic-key \
--image ironic-hpc-centos7  --nic net-id=4d5fd01c-4be6-4de2-b24e-68df725b809b bm1

nova boot --user-data cloudinit/userdata.txt \
--flavor my-baremetal-flavor --key-name ironic-key \
--image ironic-hpc-centos7 --nic net-id=4d5fd01c-4be6-4de2-b24e-68df725b809b bm2

