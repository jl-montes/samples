#!/bin/bash

user="tocp"
pass="tocp"
ipmi_ip=$1

if [ "$(fping -q -a -r 2 $ipmi_ip)" = "$ipmi_ip" ]; then
	ipmitool -H $ipmi_ip -U $user -P $pass power off
	ipmitool -H $ipmi_ip -U $user -P $pass chassis bootdev pxe
	ipmitool -H $ipmi_ip -U $user -P $pass power on
        #ipmitool -H $ipmi_ip -U $user -P $pass bmc reset cold
	exit
else
	echo "$ipmi_ip is not reachable and/or is not a valid address"
	exit
fi
