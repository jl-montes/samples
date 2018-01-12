#!/bin/bash

echo -e "--> Running Scaleio mount only script to mount existing volumes that may have been dis-mounted by recent maintenance "

IP=`ifconfig cbr0 | grep inet -m 1 | awk -F " " '{print $2}'`

mount_volume ()
{
   if grep -qs '$1' /proc/mounts; then
      echo "Volume already mounted..."
   else
      echo "It's not mounted."
      sudo mount /dev/$21 $1
   fi
}

case "$IP" in
  "10.200.66.1")
    mount_volume "/home/montana/ssre/scaleio-volume"   scinia
    ;;
  "10.200.67.1")
    mount_volume "/home/montana/ssre/scaleio-volume"  scinia
    ;;
  "10.200.98.1")
    mount_volume "/home/montana/ssre/scaleio-volume" scinia
    ;;
  "10.200.99.1")
    mount_volume "/home/montana/ssre/scaleio-volume" scinia
    ;;
  "10.200.130.1")
    mount_volume "/home/montana/ssre/scaleio-volume"  scinia
    ;;
  "10.200.131.1")
    mount_volume "/home/montana/ssre/scaleio-volume"  scinia
    ;;
esac


