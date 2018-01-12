#!/bin/bash
#

# setting up montana user wit default credentials
#Setup credentials in a secrets vault, then update this script to pull creds
#USER=$USER
#PWD=$PWD"

if [[ $1 = "" ]]
then
  echo No hostname
  exit 1
fi


RACADM="/opt/dell/srvadmin/bin/idracadm7 --nocertwarn"
CREDS="-u $USER -p $PWD"
HOST="-r $1"

$RACADM $CREDS $HOST serveraction powerup


