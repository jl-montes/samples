#!/bin/bash
USER=$1
PWD=$2

echo -e "--> Running Scaleio MDM destroy commands..."

VOL=$1
SDC=$2

unmap_volume ()
{
   echo -e "Unmapping volume.."
   /opt/bin/scli --unmap_volume_from_sdc --volume_name $1  --sdc_ip $2  --i_am_sure
}

remove_volume ()
{
   echo -e "Removing volume.."
   /opt/bin/scli --remove_volume --volume_name $1 --i_am_sure
}


/opt/bin/scli --login --username $1 --password $2



unmap_volume $VOL $SDC  

remove_volume $VOL


