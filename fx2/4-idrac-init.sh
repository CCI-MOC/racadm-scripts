#!/bin/bash

#
# ./4-idrac-init.sh <csv file> <remote pass> [new idrac pass]
#

runCMD () {
    cur_cmd=$1
    echo "[CMD] $cur_cmd"
    $cur_cmd
}

csv_file=$1
remote_pass=$2
new_pass=$3
only_this=$4

remote_user="root"

while IFS=, read -r service_tag blade_type sys_type sys_name slot rack unum ipnum mac nic1 nic2
do
    if [ "$ipnum" != "" ] && [ "$ipnum" != $only_this ]; then
        continue
    fi

    remote_cmd="racadm -r $ipnum -u $remote_user -p $remote_pass"

    if [ "$sys_type" == "idrac" ]; then
        # Set New Password
        if [ "$new_pass" != "" ]; then
            # set new password
            runCMD "$remote_cmd set iDRAC.Users.2.Password $new_pass"
            
            # reset password in remote_cmd command
            remote_cmd="racadm -r $ipnum -u $remote_user -p $new_pass"
        fi

        # Set Hostname
        runCMD "$remote_cmd set System.ServerOS.Hostname $sys_name"

        # Enable IPMI over LAN
        runCMD "$remote_cmd set iDRAC.IPMILan.Enable 1"

        # Set boot device to PXE
        runCMD "$remote_cmd config -g cfgServerInfo -o cfgServerBootOnce 0"
        runCMD "$remote_cmd config -g cfgServerInfo -o cfgServerFirstBootDevice PXE"
    fi
done < <(cat $csv_file)
