#!/bin/bash

user="tocp"
pass="tocp"
ipmi_ip=$1

if [ "$(fping -q -a -r 2 $ipmi_ip)" = "$ipmi_ip" ]; then
	ipmitool -H $ipmi_ip -U $user -P $pass power off
	exit
else
	echo "$ipmi_ip is not reachable and/or is not a valid address"
	exit
fi
