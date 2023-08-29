#!/bin/bash

#
# Usage: ./3-idrac-dhcp.sh <csv file> <remote pass>
#

runCMD () {
    cur_cmd=$1
    echo "[CMD] $cur_cmd"
    $cur_cmd
}

csv_file=$1
remote_pass=$2

remote_user="root"

while IFS=, read -r sys_type sys_name slot rack unum ipnum mac
do
    remote_cmd="racadm -r $ipnum -u $remote_user -p $remote_pass"

    if [ "$sys_type" == "cmc" ]; then
        # Get all Slots in the server
        serverlist=($("$remote_cmd getversion" | grep server | awk '{print $1;}'))

        for i in "${serverlist[@]}"; do
            runCMD "$remote_cmd setniccfg -m $i -d"
        done
    fi
done < <(cat $csv_file)
