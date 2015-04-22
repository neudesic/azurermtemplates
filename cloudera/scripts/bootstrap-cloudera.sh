#!/usr/bin/env bash
# Usage: bootstrap-cloudera-1.0.sh {clusterName} {managment_node} {cluster_nodes} {isHA} {sshUserName} [{sshPassword}]

execname=$0

log() {
  echo "[${execname}] $@" 
}

log "BEGIN: Processing text stream from Azure ARM call"

log "expected input string from Azure ARM"

ClusterName=$1 
ManagementNode=$2
ClusterNodes=$3
HA=$4
User=$5
Password=$6

log "set private key"
file="/home/$User/.ssh/id_rsa"
key="/tmp/id_rsa.pem"
openssl rsa -in $file -outform PEM > $key

log "remove requiretty"
sed -i 's^requiretty^!requiretty^g' /etc/sudoers
log "done removing requiretty"

log "cm ip fix"
#CM IP fix. Strips back ticks and creates the format getting the IP address.
CM_IP=$(echo $ManagementNode | sed 's/:/ /' | sed 's/:/ /') 
echo "$CM_IP" >> /etc/hosts

OIFS=$IFS
IFS=':'
mip=''
for x in $CM_IP
do
	#sed 's/://'
	mip=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 1)
	log "CM IP: $mip" 	
done
IFS=OIFS

log "Cluster Name: $ClusterName and User Name: $User"

log "worker name fix"
#Worker string fix. Strips back ticks and creates the format for /etc/hosts file
Worker_IP=$ClusterNodes 
log $Worker_IP

#echo $Worker_IP
wip_string=''
OIFS=$IFS
IFS=','
for x in $Worker_IP
do
	line=$(echo "$x" | sed 's/:/ /' | sed 's/:/ /')
	log "Worker IP: $line"
	echo "$line" >> /etc/hosts
	wip_string+=$(echo "$line" | cut -d ' ' -f 1 | sed 's/$/,/')
done
IFS=OIFS
worker_ip=$(echo "${wip_string%?}")
#echo "$worker_ip"
log "$worker_ip"

log "END: processing text stream from Azure ARM call"

log "BEGIN: Copy hosts file to all nodes"

OIFS=$IFS
IFS=','

for node in $ClusterNodes
do
	remote=$(echo "$node" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 2)
	log "Copy hosts file to: $remote"
	scp -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa /etc/hosts $User@$remote:/tmp/hosts 
	ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa $User@$remote sudo cp /tmp/hosts /etc/hosts 
    ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa $User@$remote "sudo bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'"
    ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa $User@$remote "sudo bash -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'"
    ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa $User@$remote "echo vm.swappiness=1 | sudo tee -a /etc/systctl.conf; sudo echo 1 | sudo tee /proc/sys/vm/swappiness"
    ssh -o StrictHostKeyChecking=no -i /home/$User/.ssh/id_rsa $User@$remote "sudo yum install -y ntp; sudo service ntpd start; sudo service ntpd status"
done

sudo yum install -y ntp
sudo service ntpd start
sudo service ntpd status

#log "About to format all disks in cluster"
#chmod 777 ./diskFormatAndMount.sh
#log "Done chmodding run file"

ClusterNodes=("${ClusterNodes[@]}" $ManagementNode)

#./diskFormatAndMount.sh ${ClusterNodes[@]}

log "Just completed formatting all disks in cluster"

IFS=OIFS

log "END: Copy hosts file to all nodes"

log "BEGIN: Starting detached script to finalize initialization"
sh initialize-cloudera-server.sh "$ClusterName" "$key" "$mip" "$worker_ip" $HA $User $Password >/dev/null 2>&1
log "END: Detached script to finalize initialization running. PID: $!"