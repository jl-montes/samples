#!/bin/bash
# arguments to pass are 
#  <volumeSizeinGBytes> <VolumeName> <StoragePoolName> <ProtectionDomain> <SDS IP address>
echo -e "--> Running Scaleio MDM setup commands..."
USER=$1
PWD=$2

/opt/bin/scli --login --username $1 --password $2

# size in GBytes
SIZE=$1
VOL=$2
#Storage PoolName
SP=$3
#Protection Domain Name
PD=$4
#SDC Node IP
SDC=$5


map_volume ()
{
   echo "Mapping Volume..."
   /opt/bin/scli --map_volume_to_sdc --volume_name $1 --sdc_ip $2
}


add_volume ()
{
   #pass the 
   /opt/bin/scli --query_volume --volume_name $2 
   if [ $? -eq 0 ]
   then
     echo "Volume already exists, no need to add volume..."
   else
     echo "Adding volume..."
     /opt/bin/scli --add_volume --size_gb $1  --volume_name $2  --storage_pool_name $3 --protection_domain_name $4
     map_volume $VOL $SDC
   fi

}

add_volume $SIZE $VOL $SP $PD

#map_volume $VOL $SDC

