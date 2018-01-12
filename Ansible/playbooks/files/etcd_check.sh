HOST=`hostname -s`
IP=`ifconfig cbr0 | grep inet -m 1 | awk -F " " '{print $2}'`

echo -e "*** Check for etcd certificate files ***"
ls -l /etc/*.crt

echo -e "*** Recursive etcd db list ***"
etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key ls --recursive

echo -e "*** Etcd cluster health-check ***"
etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key cluster-health

echo -e "*** Write value to etcd db ***"
etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key mk /ssre/test/$HOST $IP

echo -e "*** Read value from etcd db ***"
etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key get /ssre/test/$HOST

echo -e "*** Delete value from etcd db ***"
etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key rm /ssre/test/$HOST
