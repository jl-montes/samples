#!/bin/bash


gluster_set_quotas ()
{
   echo -e "--> Setting volume quota for volume $1 size=$2GB ..."
   docker exec gluster_deploy_test-1 gluster volume quota $1 enable
   docker exec gluster_deploy_test-1 gluster volume quota $1 limit-usage / $2GB

}

#gluster_set_quotas $1  $2    $1=existing volume name  $2=size in GB (pass only the number)


# Tools team volumes
gluster_set_quotas tools1 500
gluster_set_quotas tools 500

#vzcloud related volumes
gluster_set_quotas dv_chunk 100
gluster_set_quotas dv_repo 100
gluster_set_quotas hadoop 100
gluster_set_quotas logs 100
gluster_set_quotas mysqlbackup 100
gluster_set_quotas quarantine 100
gluster_set_quotas salroot 100
gluster_set_quotas scratch 100
gluster_set_quotas storage 100

#Portal team volume
gluster_set_quotas ssrede 25
