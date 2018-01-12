#!/bin/bash


create_key ()
{
   echo -e "Creating etcd keys... $1 $2"
   etcdctl --endpoint=10.200.10.1:4001  mk $1 $2
}

get_key ()
{
   echo -e "Get etcd keys... $1"
   etcdctl --endpoint=10.200.10.1:4001 get $1
}


create_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrstart" 198.159.192.103
create_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrend" 198.159.192.105

create_key "/montana/extservice/bgp/DEVNET/asnumber" 100
create_key "/montana/extservice/bgp/DEVNET/bgpneighbor/ipv4" 10.200.254.1


echo -e "Create IDN keys..."
create_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrstart" 10.77.182.102
create_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrend" 10.77.182.107

echo -e "Create IDN BGP Keys..."
create_key "/montana/extservice/bgp/IDN/asnumber" 100
create_key "/montana/extservice/bgp/IDN/bgpneighbor/ipv4" 10.200.254.1


echo -e "\nShow created etcd keys..."
get_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrstart"
get_key "/montana/extservice/MontstDEVNET/DEVNET/ipv4/0/addrend"
get_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrstart"
get_key "/montana/extservice/MontstIDN/IDN/ipv4/0/addrend"
get_key "/montana/extservice/bgp/DEVNET/asnumber"
get_key "/montana/extservice/bgp/DEVNET/bgpneighbor/ipv4"

