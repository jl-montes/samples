#/bin/bash

make_key()
{
   etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key mk $1 $2
}

#HOST=`hostname -s`
#IP=`ifconfig cbr0 | grep inet -m 1 | awk -F " " '{print $2}'`


echo -e "*** Create etcd keys for Recursive etcd db list ***"
make_key /montana/service/akira/marathon_user dcos
make_key /montana/service/akira/marathon_pass "user@123"
make_key /montana/service/akira/mesos_user dcos
make_key /montana/service/akira/mesos_pass "user@123"


