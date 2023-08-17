#!/bin/bash

#
# Usage: ./fx2-cmc-idrac-init.sh <REMOTE_IP> <passwd>
#

get_next_ip() {
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
}

# Arguments
remote_cmc=$1
remote_pass=$2

remote_user="root"

# Define remote command
remote_cmd="racadm -r $remote_cmc -u $remote_user -p $remote_pass"

# Get all Slots in the server
echo "Finding iDracs in CMC..."
cur_cmd="$remote_cmd getversion"
echo "[CMD] $cur_cmd"
serverlist=($($cur_cmd | grep server | awk '{print $1;}'))

# Setting configuration on iDracs
get_next_ip $remote_cmc
remote_cmc=$NEXT_IP
for i in "${serverlist[@]}"; do
    remote_cmd="racadm -r $remote_cmc -u $remote_user -p $remote_pass"

    # get hw inventory
    cur_cmd="$remote_cmd hwinventory"
    echo "[CMD] $cur_cmd"
    cur_hw=$($cur_cmd)

    cur_cpus=$(echo "$cur_hw" | grep "Intel(R) Xeon(R)")
    echo "$cur_cpus"

    # Increment IP num
    get_next_ip $remote_cmc
    remote_cmc=$NEXT_IP
done
