#!/bin/bash
# spawnUser.sh

hadoopUser=hadoop1
hadoopPassword=Newyork1
hadoopGroup=hadoop_group

_sshDir=/home/$hadoopUser/.ssh
_pubKey=id_rsa.pub
_privKey=id_rsa

#######
echo "...Adding dedicated Hadoop system user ($hadoopUser)"

sudo addgroup $hadoopGroup
echo -e "$hadoopPassword\n$hadoopPassword" | \
sudo adduser --ingroup $hadoopGroup $hadoopUser
sudo adduser $hadoopUser sudo

#######
echo "...Generating an SSH key pair for $hadoopUser"
ssh-keygen -t rsa -f $hadoopUser -P ""


#######
echo "...creating SSH directories and moving keys"

mkdir $_sshDir
mv ${hadoopUser}.pub $_sshDir/$_pubKey
mv $hadoopUser $_sshDir/$_privKey

#######
echo "...Enabling SSH access to local machine"
cat $_sshDir/$_pubKey >> $_sshDir/authorized_keys

#######
echo "...Setting permissions"

chmod 700 $_sshDir #SET PERMISSION
chmod 644 $_sshDir/authorized_keys
chmod 600 $_sshDir/$_privKey
chmod 644 $_sshDir/$_pubKey

chown $hadoopUser:$hadoopGroup $_sshDir/$_privKey
chown $hadoopUser:$hadoopGroup $_sshDir/$_pubKey
chown $hadoopUser:$hadoopGroup $_sshDir/authorized_keys
chown $hadoopUser:$hadoopGroup $_sshDir

#######
echo "...restarting ssh service"

service ssh restart
