#!/bin/bash
IPPREFIX=$1
NAMEPREFIX=$2
NAMENODES=$3
DATANODES=$4

echo "$IPPREFIX.9 ${NAMEPREFIX}-MN ${NAMEPREFIX}-MN" >> /etc/hosts

for (( i=0; i<=$NAMENODES; i++))
do
  let "IP=i+10"
  echo "$IPPREFIX.$IP ${NAMEPREFIX}-NN$i ${NAMEPREFIX}-NN$i" >> /etc/hosts  
done

for (( i=0; i<=$DATANODES; i++))
do
  let "IP=i+20"
  echo "$IPPREFIX.$IP ${NAMEPREFIX}-DN$i ${NAMEPREFIX}-DN$i" >> /etc/hosts  
done