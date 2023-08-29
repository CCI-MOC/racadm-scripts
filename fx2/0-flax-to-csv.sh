#!/bin/bash

#
# Usage: ./fx2-flax-to-csv.sh r4pac21-flax.txt R4-PA-C21 10.2.10
# CSV headers are: hostname,cmcname,rack,unumber,ip,mac_address
#

source_file=$1
rack_name=$2
ip_prefix=$3

cur_u="U00"
cur_unum=0
cur_ip=0
cur_servercount=0
while read line; do
    line_arr=($line)
    if [[ $line == =====* ]]; then
        # Found header line
        if [[ ${line_arr[3]} == CMC* ]]; then
            continue
        fi

        cur_u=${line_arr[1]}
        cur_unum=$(echo $cur_u | grep -o -E '[0-9]+' | head -1 | sed 's/^0*//')
        cur_ip=$((($cur_unum + 1) / 2))
        cur_servercount=1

        cur_cmcip="$ip_prefix.${cur_ip}0"
        cur_hostname="MOC-${rack_name//-/}$cur_u-CMC"

        echo "cmc,$cur_hostname,,$rack_name,$cur_unum,$cur_cmcip,${line_arr[3]}"
    fi

    if [[ $line == Server* ]]; then
        # Found server line
        cur_servername="${line_arr[0]}"
        cur_serverstr=$(echo "${cur_servername/Server-/S}" | awk '{print toupper($0)}')
        cur_serverip=$ip_prefix.$cur_ip$cur_servercount
        cur_hostname="MOC-${rack_name//-/}$cur_u-$cur_serverstr-OBM"

        echo "idrac,$cur_hostname,$cur_servername,$rack_name,$cur_unum,$cur_serverip,${line_arr[2]}"

        cur_servercount=$(($cur_servercount + 1))
    fi
done < "${source_file}"
