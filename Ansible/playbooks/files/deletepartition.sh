#!/bin/bash

DEVICE=${1}
PARTITION=${DEVICE}1
PARTITION_NUMBER=1
MNTPATH=`mount | awk '{print $3}' | grep gluster`
REMOVEDIR=`dirname ${MNTPATH}`

if [ -b ${PARTITION} ]; then

  echo "CAUTION: UNINTENDED USE OF THIS SCRIPT WILL GET RID OF ALL THE DATA ON THAT DEVICE."
  read -p "Are you sure you want to delete data from partition $PARTITION ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting a parition on $DEVICE"
    sudo umount ${MNTPATH}
    sudo wipefs -o 0x0 ${PARTITION}
    sudo parted -s ${DEVICE} rm ${PARTITION_NUMBER}
    sudo partprobe ${DEVICE}
    sudo rm -rf ${REMOVEDIR}
  else
    echo "You chose to exit; wise move"
  fi

else
    echo " No device ${PARTITION} available to delete"
fi
