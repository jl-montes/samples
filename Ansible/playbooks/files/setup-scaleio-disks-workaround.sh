#!/bin/bash


IP=`ifconfig cbr0 | grep inet -m 1 | awk -F " " '{print $2}'`
SP1=SSD
SP2=HDD
SSDLIST=`ls -l /dev/disk/by-id | grep ssd | awk '{ print $9 }'`
HDDLIST=`ls -l /dev/disk/by-id | grep hdd | awk '{ print $9 }'`
OUTFILE=/home/montana/$IP-scaleio-disks.txt

rm -v $OUTFILE

echo -e "Adding SSD drives... "
for i in $SSDLIST
do
  echo "/dev/disk/by-id/$i" >> $OUTFILE
done 

for i in $HDDLIST
do
  echo "/dev/disk/by-id/$i" >> $OUTFILE
done 


# pass the SDS-IP StoragePoolName and disk/by-id path
#add_device ()
#{
#   echo -e "Adding SDS device... "
#   scli --add_sds_device —sds_ip $1   --storage_pool_name $2 --device_path $3
#}



