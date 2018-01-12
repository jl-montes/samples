#!/bin/bash
export FLEETCTL_ENDPOINT=http://10.200.10.1:4001

#Irving, 65 total servers - MgmntNode - SecondaryMgmntNode = 63 available servers for the fleet cluster
SERVERS=63

echo -e "Checking Laniakea services...."
echo -e "Any dead, failed, re-starting, or deactivating services listed below?\n"

fleetctl list-units |grep -i -e dead -e restart -e fail -e final -e deact


num="$(fleetctl list-machines | cut -f2 | wc -l)"
count=$num
#count=`expr $num - 1`


echo -e "\nNumber of cluster members: $count of $SERVERS available..."

