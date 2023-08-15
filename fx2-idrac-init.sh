#!/bin/bash

#
# Usage: ./fx2-cmc-idrac-init.sh <REMOTE_IP> <REMOTE_HOSTNAME without postfix> <old passwd> <new passwd>
#

get_next_ip() {
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
}

# Arguments
remote_cmc=$1
remote_hostname=$2
remote_pass=$3
idrac_passwd=$4

remote_user="root"

# Define remote command
remote_cmd="racadm -r $remote_cmc -u $remote_user -p $idrac_passwd"

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

    # set hostname
    substr=$(echo "${i/server-/S}" | awk '{print toupper($0)}')
    cur_obm_hostname="$remote_hostname-$substr-OBM"
    cur_cmd="$remote_cmd set System.ServerOS.Hostname $cur_obm_hostname"
    echo "[CMD] $cur_cmd"
    $cur_cmd

    # enable ipmi over lan
    cur_cmd="$remote_cmd set iDRAC.IPMILan.Enable 1"
    echo "[CMD] $cur_cmd"
    $cur_cmd

    # set password
    cur_cmd="$remote_cmd set iDRAC.Users.2.Password $idrac_passwd"
    echo "[CMD] $cur_cmd"
    $cur_cmd

    # Increment IP num
    get_next_ip $remote_cmc
    remote_cmc=$NEXT_IP
done
