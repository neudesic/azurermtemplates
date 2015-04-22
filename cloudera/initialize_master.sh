#!/bin/bash
IPPREFIX=$1
NAMEPREFIX=$2
NAMENODES=$3
DATANODES=$4
ADMINUSER=$5

#disable the need for a tty when running sudo
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers

sh ./prepareDisks.sh

#use the key from the key vault as the SSH private key
openssl rsa -in /var/lib/waagent/*.prv -out /home/$ADMINUSER/.ssh/id_rsa
chmod 600 /home/$ADMINUSER/.ssh/id_rsa
chown $ADMINUSER /home/$ADMINUSER/.ssh/id_rsa

#TODO: pull in public key from waagent folder

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=NAMENODES-1"
for i in $(seq 0 $NAMEEND)
do 
  let "IP=i+10"
  NODES+=("10.0.0.$IP:${NAMEPREFIX}-NN$i:${NAMEPREFIX}-NN$i")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do 
  let "IP=i+20"
  NODES+=("10.0.0.$IP:${NAMEPREFIX}-DN$i:${NAMEPREFIX}-DN$i")
done

IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

echo $NODE_IPS >> /home/$ADMINUSER/node_ips.log

sh bootstrap-cloudera.sh 'cloudera' "10.0.0.9:${NAMEPREFIX}-MN:${NAMEPREFIX}-MN" $NODE_IPS false testuser >> /home/$ADMINUSER/bootstrap-cloudera.log
#sh bootstrap-cloudera.sh 'cloudera' '10.0.0.9:cloudera-MN:cloudera-MN' '10.0.0.10:cloudera-NN0:cloudera-NN0,10.0.0.11:cloudera-NN1:cloudera-NN1,10.0.0.20:cloudera-DN0:cloudera-DN0,10.0.0.21:cloudera-DN1:cloudera-DN1,10.0.0.22:cloudera-DN2:cloudera-DN2' false testuser >> /home/$1/bootstrap-cloudera.log
#sh ./bootstrap-cloudera.sh 'cloudera' '10.0.0.50:cloudera-MN:cloudera-MN' $NODE_IPS false testuser >> /home/$1/bootstrap-cloudera.log
