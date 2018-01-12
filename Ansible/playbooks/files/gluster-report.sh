#!/bin/bash

GSVC=`docker ps | grep -i gluster_deploy_test  | awk -F " " '{print $10 }'`

gluster_report ()
{
   echo -e "--> Collecting Gluster reporting data ..."
   echo -e "--> Gluster version"
   docker exec $GSVC  glusterfs --version
   
   echo -e "--> Gluster Peer status"
   docker exec $GSVC  gluster peer status
   
   echo -e "--> Gluster Volumes and status"
   docker exec $GSVC  gluster volume list
   docker exec $GSVC  gluster volume status
   docker exec $GSVC  gluster volume info all
   #echo -e "--> List any offline bricks ..."
   #docker exec $GSVC  gluster volume status | grep -i brick| grep N
}

gluster_report 


