#!/bin/bash

for i in `seq 1 8`; do
    echo -e "\n\n*** Collecting Docker Logs ***"
    docker logs gluster_deploy_test-$i
    if [ $? -eq 0 ]; then
        echo -e "The local gluster container is --> gluster_deploy_test-$i"
        break
    fi
done

