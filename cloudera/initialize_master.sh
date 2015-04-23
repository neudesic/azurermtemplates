#!/bin/bash
IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
NAMENODES=$4
DATANODES=$5
ADMINUSER=$6

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

#disable the need for a tty when running sudo
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers

sh ./prepareDisks.sh

#use the key from the key vault as the SSH private key
openssl rsa -in /var/lib/waagent/*.prv -out /home/$ADMINUSER/.ssh/id_rsa
chmod 600 /home/$ADMINUSER/.ssh/id_rsa
chown $ADMINUSER /home/$ADMINUSER/.ssh/id_rsa

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=NAMENODES-1"
for i in $(seq 0 $NAMEEND)
do 
  let "IP=i+10"
  NODES+=("10.0.0.$IP:${NAMEPREFIX}-nn$i.$NAMESUFFIX:${NAMEPREFIX}-nn$i")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do 
  let "IP=i+20"
  NODES+=("10.0.0.$IP:${NAMEPREFIX}-dn$i.$NAMESUFFIX:${NAMEPREFIX}-dn$i")
done

IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

sh bootstrap-cloudera.sh 'cloudera' "10.0.0.9:${NAMEPREFIX}-mn.$NAMESUFFIX:${NAMEPREFIX}-mn" $NODE_IPS false testuser >> /home/$ADMINUSER/bootstrap-cloudera.log