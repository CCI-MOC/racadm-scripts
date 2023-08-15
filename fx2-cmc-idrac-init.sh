#!/bin/bash

#
# Usage: ./fx2-cmc-idrac-init.sh <REMOTE_IP>
#

# Arguments
remote_cmc=$1

remote_user="root"
remote_pass="calvin"

# Define remote command
remote_cmd="racadm -r $remote_cmc -u $remote_user -p $remote_pass"

# Get all Slots in the server
echo "Finding iDracs in CMC..."
cur_cmd="$remote_cmd getversion"
echo "[CMD] $cur_cmd"
serverlist=($($cur_cmd | grep server | awk '{print $1;}'))

# Setting configuration on iDracs
echo "Setting all iDRACs to DHCP..."
for i in "${serverlist[@]}"; do
    cur_cmd="$remote_cmd setniccfg -m $i -d"
    echo "[CMD] $cur_cmd"
    $cur_cmd
done
