#!/bin/bash

#
# ./4-idrac-init.sh <csv file> <remote pass> [hostname]
#

runCMD () {
    cur_cmd=$1
    echo "[CMD] $cur_cmd"
    $cur_cmd
}

csv_file=$1
remote_pass=$2
hostname=$3
ignore_type=$4

remote_user="root"

while IFS=, read -r service_tag blade_type sys_type sys_name slot rack unum ipnum mac nic1 nic2 port
do
    if [[ $hostname != "" ]]; then
        if [[ $hostname != $sys_name ]]; then
            continue
        fi
    fi

    if [[ $ignore_type != "" ]]; then
        if [[ $ignore_type == $blade_type ]]; then
            continue
        fi
    fi

    remote_cmd="racadm -r $ipnum -u $remote_user -p $remote_pass"

    if [ "$sys_type" == "idrac" ]; then

        echo "--------------------------"
        echo "$sys_name"
        echo "--------------------------"
        echo ""

        # set boot mode to Bios
        runCMD "$remote_cmd set BIOS.BiosBootSettings.BootMode Bios"

        # set power mode to DAPC
        runCMD "$remote_cmd set BIOS.SysProfileSettings.SysProfile PerfPerWattOptimizedDapc"

        # Create job
        runCMD "$remote_cmd jobqueue create BIOS.Setup.1-1 -r pwrcycle -s TIME_NOW -e TIME_NA"
    fi
done < <(cat $csv_file)
