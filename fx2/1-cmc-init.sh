#!/bin/bash

#
# Usage: ./1-cmc-init.sh <csv file> <current password for CMC> [new password for CMC]
#

runCMD () {
    cur_cmd=$1
    echo "[CMD] $cur_cmd"
    $cur_cmd
}

csv_file=$1
remote_pass=$2
new_pass=$3

remote_user="root"

while IFS=, read -r service_tag blade_type sys_type sys_name slot rack unum ipnum mac nic1 nic2 port
do
    #if [ "$ipnum" != "" ]; then
    #    continue
    #fi

    remote_cmd="racadm -r $ipnum -u $remote_user -p $remote_pass"

    if [ "$sys_type" == "cmc" ]; then
        if [ "$new_pass" != "" ]; then
            # set new password
            runCMD "$remote_cmd config -g cfgUserAdmin -i 1 -o cfgUserAdminPassword $new_pass"
            
            # reset password in remote_cmd command
            remote_cmd="racadm -r $ipnum -u $remote_user -p $new_pass"
        fi

        # Set hostname
        runCMD "$remote_cmd setchassisname $sys_name"
    fi
done < <(cat $csv_file)