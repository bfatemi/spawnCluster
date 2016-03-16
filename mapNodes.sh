#! /bin/bash

# createCluster.sh

# AT THIS POINT WE NEED TO HAVE THESE SLAVE NODES UP AND RUNNING
echo "...Updating /etc/hosts to define master and slave network"
printf "\n\n\n%s" "45.55.115.231 master" >> /etc/hosts
printf "\n%s" "45.55.115.232 slave1" >> /etc/hosts
printf "\n%s" "45.55.115.233 slave2" >> /etc/hosts

#echo "...Sending ssh public keys to slave nodes"
#ssh-copy-id -i slave1
#ssh-copy-id -i slave2
