#!/bin/bash

source_file=$1
export dnsmasq_intf=$2

awk -F\, '{ print "dhcp-host=" ENVIRON["dnsmasq_intf"] "," $9 "," $8 "," $4 ",12h" }' $source_file
