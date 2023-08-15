#!/bin/bash

#
# Usage: ./fx2-cmc-init.sh <REMOTE_IP> <REMOTE_HOSTNAME without postfix> <cur passwd> <new passwd> <reset/empty>
#

# Arguments
remote_cmc=$1
remote_hostname=$2
remote_pass=$3
new_passwd=$4
reset_yes=$5

remote_user="root"

# Define remote command
remote_cmd="racadm -r $remote_cmc -u $remote_user -p $remote_pass"

# Set name of hostname
cur_cmd="$remote_cmd setchassisname $remote_hostname-CMC"
echo "[CMD] $cur_cmd"
$cur_cmd

# Set Pass
cur_cmd="$remote_cmd config -g cfgUserAdmin -i 1 -o cfgUserAdminPassword $new_passwd"
echo "[CMD] $cur_cmd"
$cur_cmd

# Factory reset all iDracs
if [ "$reset" == "reset" ]; then
    # Get all Slots in the server
    echo "Finding iDracs in CMC..."
    cur_cmd="$remote_cmd getversion"
    echo "[CMD] $cur_cmd"
    serverlist=($($cur_cmd | grep server | awk '{print $1;}'))

    for i in "${serverlist[@]}"; do
        cur_cmd="$remote_cmd racresetcfg -m $i"
        echo "[CMD] $cur_cmd"
        $cur_cmd    
    done
fi
