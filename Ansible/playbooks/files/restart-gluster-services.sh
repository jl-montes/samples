#!/bin/bash
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/opt/montana/services/core/cli/bin'
export FLEETCTL_ENDPOINT=http://10.200.10.1:4001

restart_gluster ()
{
   echo -e "--> Restarting Gluster services ..."
   for i in `seq 1 8`;
        do
           echo "Restarting instance $i"
           /usr/bin/fleetctl stop gluster_deploy_test@$i.service
           /usr/bin/fleetctl start gluster_deploy_test@$i.service
           echo -e "--> Sleeping 15 seconds ..."
           sleep 15 
        done  

}

restart_gluster

