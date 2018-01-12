#!/bin/bash

echo -e "--> Running Scaleio add SDS device commands..."
scli --login --username $1 --password $2

FILEPATH=/home/montana/$1-scaleio-disks.txt
INFILE=`echo $FILEPATH | cut -d '/' -f4`

IP=`echo $INFILE | cut -d '-' -f1`
SP1=SSD
SP2=HDD
#SSDLIST=`ls -l /dev/disk/by-id | grep ssd | awk '{ print $9 }'`
#HDDLIST=`ls -l /dev/disk/by-id | grep hdd | awk '{ print $9 }'`

echo -e "Processing node $IP"
  

#pass the SDS-IP StoragePoolName and disk/by-id path
add_device ()
{
   echo -e "Adding SDS device... "
   scli --add_sds_device --sds_ip $1   --storage_pool_name $2 --device_path $3
}

for i in `cat $INFILE`
do
  if [[ $i  == *"ssd"* ]]
  then
      echo -e "Adding SSD drive... "
      add_device $IP $SP1 $i
  elif [[ $i  == *"hdd"* ]]
  then
      echo -e "Adding HDD drive... "
      add_device $IP $SP2 $i    
  fi
  
done 

