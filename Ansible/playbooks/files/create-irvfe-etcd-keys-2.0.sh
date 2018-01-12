#!/bin/bash


create_key ()
{
   etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key mk $1 $2  
   if [ $? -eq 0 ]
   then
      echo "Successfully created key"
   else
      echo "Could not create key, already exist..."
      echo "Updating keys..."
      etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key update $1 $2
   fi
}

get_key ()
{
   echo "Retrieving $1"
   etcdctl --ca-file=/etc/ca.crt --cert-file=/etc/etcd_client.crt --key-file=/etc/etcd_client.key get $1   
}


echo -e "Create DEVNET keys..."
create_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrstart" 198.159.192.130
create_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrend" 198.159.192.191

echo -e "Create IDN keys..."
create_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrstart" 10.77.182.102
create_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrend" 10.77.182.107

echo -e "Create DEVNET2 experimental keys..."
create_key "/montana/extservice/MontstDEVNET/DEVNET2/ipv4/0/addrstart" 198.159.192.130
create_key "/montana/extservice/MontstDEVNET/DEVNET2/ipv4/0/addrend" 198.159.192.191

create_key "/montana/extservice/bgp/DEVNET2/remoteasnumber"  64512
create_key "/montana/extservice/bgp/DEVNET2/asnumber"   64681
create_key "/montana/extservice/bgp/DEVNET2/bgpneighbor/ipv4" 169.254.0.1


echo -e "Get etcd keys..."
get_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrstart"
get_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrend" 

get_key "/montana/extservice/MontstDEVNET/DEVNET2/ipv4/0/addrstart"
get_key "/montana/extservice/MontstDEVNET/DEVNET2/ipv4/0/addrend" 

get_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrstart"
get_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrend"

get_key "/montana/extservice/bgp/DEVNET2/remoteasnumber"
get_key "/montana/extservice/bgp/DEVNET2/asnumber"
get_key "/montana/extservice/bgp/DEVNET2/bgpneighbor/ipv4"



