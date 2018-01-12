#!/bin/bash
#

# setting up montana user wit default credentials
#

if [[ $1 = "" ]]
then
  echo No hostname
  exit 1
fi


RACADM="/opt/dell/srvadmin/bin/idracadm7 --nocertwarn"
#Setup credentials in a secrets vault, then update this script to pull creds
#CREDS="-u test -p test"

HOST="-r $1"

$RACADM $CREDS $HOST serveraction powercycle

