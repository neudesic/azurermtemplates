#!/bin/bash

#disable the need for a tty when running sudo
sed -i '/Defaults[[:space:]]\+!*requiretty/s/^/#/' /etc/sudoers

sh ./prepareDisks.sh

#TODO: pull in public key from waagent folder
