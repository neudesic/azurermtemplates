#!/bin/bash
set -e
set -x

# USAGE: Provide a set of hosts on which you would like to operate. They must be an array

hosts=("${@}")

User=
for host in ${hosts[@]};
do
  remote=$(echo "$host" | sed 's/:/ /' | sed 's/:/ /' | cut -d ' ' -f 2)
  echo "remote: $remote"
  sudo -u $User ssh -o "StrictHostKeyChecking=false" -tt $remote -x << 'EOF' &
    set +e
    set +x
    echo "hi";
    hostname
    sudo whoami
   
    # ok this is the fun part. Let's create a file here
    cat > inputs2.sh << 'END'
      
      helloFromInputs() {
        
        echo "hello from printinputs.sh"
      }

      printFstab() {
        echo "Here is the fstab from `hostname`"
        cat /etc/fstab
        echo "Now sudo print fstab from `hostname`"
        sudo cat /etc/fstab
      }


    mountDrive() {

      driveName=$1
      driveId=$2
      echo "$(hostname) : /data${2} :About to mount drive"
      mount -o noatime -t ext4 ${1} /data${2}
      echo "$driveName   /data${2}    ext4   defaults,noatime 1 2" | sudo tee -a /etc/fstab
      cat /etc/fstab
      echo "$(hostname) : /data${2} : Done mounting drive"

    }

    unmountDrive() {

      driveName=$1
      driveId=$2
      echo "$(hostname) : /data${2} : About to unmount drive"
      umount ${1}
      df -h
      echo "$(hostname) : /data${2} : now let's try it with sudo"
      sudo umount ${1}

      echo "$(hostname) : /data${2} :done trying it with sudo"
      echo "$(hostname) : /data${2} :Done unmounting drive $(hostname): $1"

    }

    formatAndMountDrive() {
      echo "$(hostname) : $1 : Beginning operation on drive" || true
      echo "$(hostname) : $1 : Formatting drive for ext4" || true
      drive=$1
      echo "$(hostname) : $1 : set drive and execute"
      mke2fs -F -t ext4 -b 4096 -O sparse_super,dir_index,extent,has_journal -m1 $drive
      echo "$(hostname) : $1 : should be done formatting now"

      echo "$(hostname) : $1 : attempt to format exit code: $?"
      echo "$(hostname) : $1 : Mounting drive $1"
      echo "$(hostname) : $1 : About to make dir /data${2}"
      rm -rf /data${2} || true
      mkdir -p /data${2}
      chmod 777 /data${2}
      echo "$(hostname) : $1 : after data creation for id $2: $?"
      mount -o noatime -t ext4 ${1} /data${2}
      echo "$driveName   /data${2}    ext4   defaults,noatime 1 2" | sudo tee -a /etc/fstab
      echo "$(hostname) : $1 : after mounting for id $2 exit code: $?"
      echo "$(hostname) : $1 : Done operating on drive $1. Here is df -h"
      df -h
      echo "$(hostname) : $1 :  done"
    }

    mountAllDrives() {
      echo "Mounting all drives"
      let i=0 || true
      for x in $(sfdisk -l 2>/dev/null | cut -d' ' -f 2 | grep /dev | grep -v "/dev/sda" | grep -v "/dev/sdb" | sed "s^:^^");
      do
        echo "$(hostname) : $x : About to mount drive for $(hostname): $x"
        mountDrive $x $i
        let i=(i+1) || true
      done
    }

    unmountAllDrives() {
      let i=0 || true
      for x in $(sfdisk -l 2>/dev/null | cut -d' ' -f 2 | grep /dev | grep -v "/dev/sda" | grep -v "/dev/sdb" | sed "s^:^^");
      do
        echo "$(hostname) : $x : About to call unmountDrive"
        unmountDrive $x $i  0</dev/null &
        let i=(i + 1) || true
      done
      wait
      echo "$(hostname) : Done unmounting on $(hostname). Drives look like: "
      df -h
    }

    formatAndMountAllDrives() {
      echo "Entered formatAndMountAllDrives on `hostname`"
      let i=0 || true
      for x in $(sfdisk -l 2>/dev/null | cut -d' ' -f 2 | grep /dev | grep -v "/dev/sda" | grep -v "/dev/sdb" | sed "s^:^^");
      do
        echo "$(hostname) : $(x): About to call formatAndMountDrive)"
        formatAndMountDrive $x $i  0</dev/null &
        let i=(i + 1) || true
      done
      wait
    }


END
    sudo bash -c "source ./inputs2.sh; helloFromInputs; printFstab; unmountAllDrives;  formatAndMountAllDrives;"
    exit 0  # and this is useful
EOF
done
wait  # until all threads return
echo "Done formatting and mounting all available drives. About to hard exit"
exit 0
echo "This should not be printed...because it is after the exit."
