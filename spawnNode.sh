#!/bin/bash

# spawnNode.sh

### Install packages
hadoop_mirror="http://mirrors.ibiblio.org/apache/hadoop/common/current/hadoop-2.7.2.tar.gz"
hadoop_Path="/usr/local/hadoop"

#echo "...Adding dedicated Hadoop system user"
#sudo addgroup hadoop_group
#sudo adduser --ingroup hadoop_group hduser1
#sudo adduser hduser1 sudo 

#echo "...Generating an SSH key for the hduser"
#su - hduser1
#ssh-keygen -t rsa -P ""

#echo "...Enabling SSH access to local machine"
#cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

# fetch and install hadoop
echo "...Downloading Hadoop"
wget $hadoop_mirror |pv -tpe -N "Downloading Hadoop" > /dev/null

echo ...Unziping file
tar xfz hadoop-2.7.2.tar.gz |pv -tpe -N "Unziping Hadoop Files" > /dev/null

echo ...Creating hadoop directory
mv hadoop-2.7.2 $hadoopPath |pv -tpe -N "Moving Hadoop Files" > /dev/null

echo ...Updating .bashrc to include Hadoop Variables
printf "\n\n\n%s\n" "#HADOOP VARIABLES START" >> ~/.bashrc
printf "%s\n" "export JAVA_HOME=$jhome" >> ~/.bashrc
printf "%s\n" "export HADOOP_INSTALL=$hadoopPath" >> ~/.bashrc
printf "%s\n" "export PATH=\$PATH:\$HADOOP_INSTALL/bin" >> ~/.bashrc
printf "%s\n" "export PATH=\$PATH:\$HADOOP_INSTALL/sbin" >> ~/.bashrc
printf "%s\n" "export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL" >> ~/.bashrc
printf "%s\n" "export HADOOP_COMMON_HOME=\$HADOOP_INSTALL" >> ~/.bashrc
printf "%s\n" "export HADOOP_HDFS_HOME=\$HADOOP_INSTALL" >> ~/.bashrc
printf "%s\n" "export YARN_HOME=\$HADOOP_INSTALL" >> ~/.bashrc
printf "%s\n" "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_INSTALL/lib/native" >> ~/.bashrc
printf "%s\n" "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\"" >> ~/.bashrc
printf "%s\n" "#HADOOP VARIABLES END" >> ~/.bashrc

echo ...Sourcing bashrc file
source ~/.bashrc

echo ...Updating /usr/local/hadoop/etc/hadoop/hadoop-env.sh
sed -i "s@export JAVA_HOME=.*@export JAVA_HOME=$jhome@1" $hadoopPath/etc/hadoop/hadoop-env.sh

echo ...Updating /usr/local/hadoop/etc/hadoop/core-site.xml
xmlstarlet ed -L -s /configuration -t elem -n 'TEMP_property' -v '' \
        -s //TEMP_property -t elem -n 'TEMP_name' -v 'fs.default.name' \
        -s //TEMP_property -t elem -n 'TEMP_value' -v 'hdfs://localhost:9000' \
	$hadoopPath/etc/hadoop/core-site.xml

xmlstarlet ed -L -r '//TEMP_property' -v 'property' $hadoopPath/etc/hadoop/core-site.xml
xmlstarlet ed -L -r '//TEMP_name' -v 'name' $hadoopPath/etc/hadoop/core-site.xml
xmlstarlet ed -L -r '//TEMP_value' -v 'value' $hadoopPath/etc/hadoop/core-site.xml

echo ...Updating /usr/local/hadoop/etc/hadoop/yarn-site.xml
xmlstarlet ed -L -s /configuration -t elem -n 'TEMP_property_1' -v '' \
        -s //TEMP_property_1 -t elem -n 'TEMP_name_1' -v 'yarn.nodemanager.aux-services' \
        -s //TEMP_property_1 -t elem -n 'TEMP_value_1' -v 'mapreduce_shuffle' \
	-s /configuration -t elem -n 'TEMP_property_2' -v '' \
        -s //TEMP_property_2 -t elem -n 'TEMP_name_2' -v 'yarn.nodemanager.aux-services.mapreduce.shuffle.class' \
        -s //TEMP_property_2 -t elem -n 'TEMP_value_2' -v 'org.apache.hadoop.mapred.ShuffleHandler' \
        $hadoopPath/etc/hadoop/yarn-site.xml

xmlstarlet ed -L -r '//TEMP_property_1' -v 'property' $hadoopPath/etc/hadoop/yarn-site.xml
xmlstarlet ed -L -r '//TEMP_name_1' -v 'name' $hadoopPath/etc/hadoop/yarn-site.xml
xmlstarlet ed -L -r '//TEMP_value_1' -v 'value' $hadoopPath/etc/hadoop/yarn-site.xml

xmlstarlet ed -L -r '//TEMP_property_2' -v 'property' $hadoopPath/etc/hadoop/yarn-site.xml
xmlstarlet ed -L -r '//TEMP_name_2' -v 'name' $hadoopPath/etc/hadoop/yarn-site.xml
xmlstarlet ed -L -r '//TEMP_value_2' -v 'value' $hadoopPath/etc/hadoop/yarn-site.xml

echo ...Updating /usr/local/hadoop/etc/hadoop/mapred-site.xml
cp $hadoopPath/etc/hadoop/mapred-site.xml.template $hadoopPath/etc/hadoop/mapred-site.xml

xmlstarlet ed -L -s /configuration -t elem -n 'TEMP_property' -v '' \
        -s //TEMP_property -t elem -n 'TEMP_name' -v 'mapreduce.framework.name' \
        -s //TEMP_property -t elem -n 'TEMP_value' -v 'yarn' \
       $hadoopPath/etc/hadoop/mapred-site.xml

xmlstarlet ed -L -r '//TEMP_property' -v 'property' $hadoopPath/etc/hadoop/mapred-site.xml
xmlstarlet ed -L -r '//TEMP_name' -v 'name' $hadoopPath/etc/hadoop/mapred-site.xml
xmlstarlet ed -L -r '//TEMP_value' -v 'value' $hadoopPath/etc/hadoop/mapred-site.xml

echo ...Updating /usr/local/hadoop/etc/hadoop/hdfs-site.xml
configFile="$hadoopPath/etc/hadoop/hdfs-site.xml"

nnPath='/usr/local/hadoop_store/hdfs/namenode'
dnPath='/usr/local/hadoop_store/hdfs/datanode'

mkdir -p $nnPath
mkdir -p $dnPath

xmlstarlet ed -L \
	-s /configuration -t elem -n 'TEMP_property_1' -v '' \
	-s //TEMP_property_1 -t elem -n 'TEMP_name_1' -v 'dfs.replication' \
	-s //TEMP_property_1 -t elem -n 'TEMP_value_1' -v 1 \
      	\
	-s /configuration -t elem -n 'TEMP_property_2' -v '' \
	-s //TEMP_property_2 -t elem -n 'TEMP_name_2' -v 'dfs.namenode.name.dir' \
        -s //TEMP_property_2 -t elem -n 'TEMP_value_2' -v "file:$nnPath" \
        \
	-s /configuration -t elem -n 'TEMP_property_3' -v '' \
        -s //TEMP_property_3 -t elem -n 'TEMP_name_3' -v 'dfs.datanode.data.dir' \
        -s //TEMP_property_3 -t elem -n 'TEMP_value_3' -v "file:$dnPath" \
        $configFile

xmlstarlet ed -L -r '//TEMP_property_1' -v 'property' $configFile
xmlstarlet ed -L -r '//TEMP_name_1' -v 'name' $configFile
xmlstarlet ed -L -r '//TEMP_value_1' -v 'value' $configFile

xmlstarlet ed -L -r '//TEMP_property_2' -v 'property' $configFile
xmlstarlet ed -L -r '//TEMP_name_2' -v 'name' $configFile
xmlstarlet ed -L -r '//TEMP_value_2' -v 'value' $configFile

xmlstarlet ed -L -r '//TEMP_property_3' -v 'property' $configFile
xmlstarlet ed -L -r '//TEMP_name_3' -v 'name' $configFile
xmlstarlet ed -L -r '//TEMP_value_3' -v 'value' $configFile

echo "...Formating the New Hadoop Filesystem"
hdfs namenode -format 

echo "...Starting Hadoop & Yarn"
start-dfs.sh
start-yarn.sh

echo "...Installation Complete"
jps

