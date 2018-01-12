#!/bin/bash
# J. Montes - Verizon Product Deve;lopment team
# john.montes@verizon.com
# 972-232-3605


show-status ()
{
   echo -e "\nChecking system uptime and average load..." 
   w | grep load
   
   echo -e "\nChecking disk space consumption..."
   df -h 
  
   echo -e "\nChecking systemctl overall system status..." 
   sudo systemctl is-system-running
}

clean-containers ()
{
   echo -e "\nCleaning up non running containers..."
   #Remove all non-running containers -
   sudo docker rm $(sudo docker ps -q -f status=exited)

}

clean-images ()
{

   echo -e "\nCleaning up dangling and un-tagged images..."
   #Delete all 'untagged/dangling' (<none>) images - 
   sudo /usr/bin/docker rmi $(sudo /usr/bin/docker images -q -f dangling=true)
   #Remove all images - 
   #sudo docker rmi $(sudo docker images -q)

   #Remove all "untagged" images - 
   sudo /usr/bin/docker rmi $(sudo /usr/bin/docker images | grep "^<none>" | awk "{print $3}") 

}

clean-journal ()
{
   echo -e "\nCleaning up journal logs..." 
   sudo journalctl --flush
   sudo journalctl --disk-usage
   #sudo journalctl --vacuum-time=3d
   echo -e "\nRestarting journald service..." 
   sudo systemctl stop systemd-journald
   sudo rm -vr /var/log/journal/* 
   sudo systemctl start systemd-journald
   sudo journalctl --verify
   
}

show-status
clean-containers
clean-images
clean-journal
