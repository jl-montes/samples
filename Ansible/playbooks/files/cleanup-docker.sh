#!/bin/bash
# J. Montes - Verizon Product Development team
# john.montes@verizon.com
# 972-232-3605


show-status ()
{
   echo -e "\nChecking docker daemon..." 
   docker ps    
   sudo systemctl status docker.service
}

clean-docker ()
{
   echo -e "\nCleaning up docker..."
   sudo rm -v  /var/lib/docker/repositories-overlay ; sudo systemctl restart docker.service
}


show-status
clean-docker

