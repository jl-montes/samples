#!/bin/bash

num=`df -h |grep -m 1 -e sd | awk '{ print $5}' | sed  's/%//'`
check=75

if [ "$num" -ge $check ]; then 
   echo "Disk consumption is $num% and >= to the threshold of $check%"
   #sudo du -sh /* 
   exit 1
else
   echo "Disk consumption is $num% and < the threshold of $check%"
   exit 0
fi

