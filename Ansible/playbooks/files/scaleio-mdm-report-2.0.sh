#!/bin/bash

echo -e "--> Collecting Scaleio information from an MDM node..."

scaleio_login ()
{
   echo -e "--> Logging into MDM node ..."
   scli --login --username **getFromSecrets** --password **getFromSecrets** --use_nonsecure_communication
}

scaleio_report ()
{
   echo -e "--> Collecting report info..."
   scli --query_all_sds  --use_nonsecure_communication
   
   echo -e ""   
   scli --query_all_sdc  --use_nonsecure_communication
 

   echo -e ""   
   scli --query_all_volumes  --use_nonsecure_communication
   
   echo -e ""   
   scli --query_all  --use_nonsecure_communication

}

scaleio_login
scaleio_report


