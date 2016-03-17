#! /bin/bash

# createCluster.sh

# Location of the hosts file on Linux and Mac systems.
hosts_file=/etc/hosts
# Regular expression to find the IP address, at the start of a line.
regex='^([0-9]+\.){3}[0-9]+'

update_host () {
  # Search for the existence of the hostname in the file.
  egrep "$regex $1" $hosts_file > /dev/null && \
  # And replace the IP address with the provided one, if found.
  { sed -i -r "s,${regex}( ${1}),$2\2,g" $hosts_file; return 0; } || \
  # Else, append a new entry.
  echo "$2 $1" >> $hosts_file
}

# AT THIS POINT WE NEED TO HAVE THESE SLAVE NODES UP AND RUNNING
echo "...Updating /etc/hosts to define master and slave network"
update_host master 45.55.115.231 
update_host slave1 45.55.115.232
update_host slave2 45.55.115.233

#echo "...Sending ssh public keys to slave nodes"
#ssh-copy-id -i slave1
#ssh-copy-id -i slave2
