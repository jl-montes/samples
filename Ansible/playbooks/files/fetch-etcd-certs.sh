#!/usr/bin/env bash

# Copyright (C) Verizon, 2016

source /etc/environment

echo "My IP: ${COREOS_PRIVATE_IPV4}"
BASEURL="http://${PROVISION_SERVER_IP}/security/montana-ca"
roles="client peer server"

for r in ${roles}
do
   sudo wget -O /etc/etcd_${r}.crt ${BASEURL}/certs/node_${COREOS_PRIVATE_IPV4}_${r}.crt
   sudo wget -O /etc/etcd_${r}.key ${BASEURL}/private/node_${COREOS_PRIVATE_IPV4}_${r}.key
   sudo wget -O /etc/ca.crt ${BASEURL}/certs/ca.crt
done

sudo systemctl restart etcd2
