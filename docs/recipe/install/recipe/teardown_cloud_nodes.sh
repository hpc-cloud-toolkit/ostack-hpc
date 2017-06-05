
## FILE: teardown_cloud_nodes.sh
#!/bin/bash
#This script is designed to be used on our internal sun-hn1 node to clean up all of our configured OpenStack
#configurations for a clean OpenStack configuration without completely uninstalling and reinstalling the
#entire OpenStack software stack.
#Source the keystone file so we have secure access to the OpenStack commands
source ${HOME}/keystonerc_admin
#First stop the compute nodes. This is done to cleanly delete the nodes. If you skip the stop step, the
#nova delete command will sometimes result in an error. This is found to be the safest way to delete
#nova nodes.
nova stop cc1
nova stop cc2
nova stop cc3
#Wait for the nova nodes to stop bing in status ACTIVE (i.e. they are now in SHUTOFF)
nova list | awk {'print $6'} | grep -v 'Status' | grep ACTIVE > /dev/null
nova_stopped=$?
until [ "${nova_stopped}" -eq "1" ]; do
    sleep 5
    nova list | awk {'print $6'} | grep -v 'Status' | grep ACTIVE > /dev/null
    nova_stopped=$?
done
#Once all the nodes are shutdown, they can safely be deleted from nova.
nova delete cc1
nova delete cc2
nova delete cc3
#Now that there are no booted nodes and association of a compute node with the ironic nodes,
#the ironic nodes can safely be deleted.
ironic node-delete cc1
ironic node-delete cc2
ironic node-delete cc3
#Once the ironic nodes are deleted, we can delete the associated neutron port that was associated with each
#of the nodes.
neutron port-delete cc1
neutron port-delete cc2
neutron port-delete cc3
#Now we can delete the shared network that was configured with neutron
neutron net-delete sharednet1
#Remove the nova flavor 'baremetal-flavor' association we created with the machine's hardware
nova flavor-delete baremetal-flavor
#Remove every image locally saved in glance
for x in `glance image-list | awk {'print $2'} | grep -v ID`; do
    glance image-delete $x
done
#Finally, remove the keypair association we have in nova. This will leave the system clean and ready for another run
nova keypair-delete ostack_key
#  
