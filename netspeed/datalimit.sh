#!/bin/bash

#T1b=`cat /sys/class/net/eth0/statistics/tx_bytes`
sum=`cat /sys/class/net/*/statistics/tx_bytes|awk '{sum+=$1} END {print sum}'`
echo $sum
#1G = 1073741824 byte
if [ $sum -gt 98784247808 ];then
        echo `date` all nics total data transferd are $sum , larger than 92g, stop tcp/udp 443 port | tee -a /root/ethdatalimit.log
        iptables -F
        iptables -A INPUT -p tcp --destination-port 443 -j DROP
        iptables -A INPUT -p udp --destination-port 443 -j DROP
else
        echo $sum less than 92g,go on
fi


#crontab -l
#0 1 1 * * reboot
#*/15 * * * * /root/datalimit.sh
