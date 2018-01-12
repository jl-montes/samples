#!/bin/bash

remove_containers ()
{
   echo -e "Removing un-used docker containers..."
   #/bin/docker rm  $(/bin/docker ps -qa )
   /usr/bin/docker rm $(/usr/bin/docker ps -qa)
}

remove_images ()
{
   echo -e "Removing un-used docker images..."
   #/bin/docker rmi $(/bin/docker images -qa)
   /usr/bin/docker rmi $(/usr/bin/docker images -qa)
}

remove_containers
remove_images

