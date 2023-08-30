#!/bin/bash

csv_file=$1
remote_pass=$2
starting_ipmi_port=$3

remote_user="root"

ipmi_deploy_kernel="42298c88-7927-4fa5-999a-a4f03a8c3272"
ipmi_deploy_ramdisk="bb5adbc2-0d7a-4993-ace4-b30a6385c9fd"

json_out=""

json_out="${json_out}{"
json_out="${json_out}\"nodes\": ["

cur_ipmi_port=$starting_ipmi_port
while IFS=, read -r service_tag blade_type sys_type sys_name slot rack unum ipnum mac
do
    if [ "$sys_type" == "idrac" ]; then
        json_out="${json_out}{"
        # Add Name of node
        json_out="${json_out}\"name\": \"$sys_name\","
        # Add Properties of node
        json_out="${json_out}\"properties\": { \"capabilities\": \"iscsi_boot:True\" },"
        # Set resource class of node
        json_out="${json_out}\"resource_class\": \"baremetal\","
        # Set driver to ipmi
        json_out="${json_out}\"driver\": \"ipmi\","
        # Set driver info
        json_out="${json_out}\"driver_info\": {"
        json_out="${json_out}\"deploy_kernel\": \"$ipmi_deploy_kernel\","
        json_out="${json_out}\"deploy_ramdisk\": \"$ipmi_deploy_ramdisk\","
        json_out="${json_out}\"ipmi_username\": \"$remote_user\","
        json_out="${json_out}\"ipmi_password\": \"$remote_pass\","
        json_out="${json_out}\"ipmi_address\": \"$ipnum\","
        json_out="${json_out}\"ipmi_terminal_port\": $cur_ipmi_port"
        json_out="${json_out}},"
        # Create Ports section
        json_out="${json_out}\"ports\": []"

        json_out="${json_out}},"

        # increment IPMI port
        #! TODO use the 10(IPNUM) model
        cur_ipmi_port=$(($cur_ipmi_port+1))
    fi
done < <(cat $csv_file)

# Remove last comma
json_out="${json_out::-1}"
json_out="${json_out}]}"

echo $json_out | jq '.'
