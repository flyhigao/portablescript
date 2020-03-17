#!/bin/bash


if [ -z "$1" ]; then
        echo
        echo usage: $0 network-interface
        echo
        echo e.g. $0 eth0
        echo
        echo shows packets-per-second
        exit
fi

IF=$1
ALLRXP=0
ALLTXP=0
ALLRXKB=0
ALLTXKB=0
echo beging counting ...
while true
do
        R1=`cat /sys/class/net/$1/statistics/rx_packets`
        T1=`cat /sys/class/net/$1/statistics/tx_packets`
        R1b=`cat /sys/class/net/$1/statistics/rx_bytes`
        T1b=`cat /sys/class/net/$1/statistics/tx_bytes`
        sleep 1
        R2=`cat /sys/class/net/$1/statistics/rx_packets`
        T2=`cat /sys/class/net/$1/statistics/tx_packets`
        R2b=`cat /sys/class/net/$1/statistics/rx_bytes`
        T2b=`cat /sys/class/net/$1/statistics/tx_bytes`
        TXPPS=`expr $T2 - $T1`
        RXPPS=`expr $R2 - $R1`

	ALLRXP=`expr $ALLRXP + $RXPPS`
	ALLTXP=`expr $ALLTXP + $TXPPS`



        TBPS=`expr $T2b - $T1b`
        RBPS=`expr $R2b - $R1b`
        TKBPS=`expr $TBPS / 128`
        RKBPS=`expr $RBPS / 128`

	ALLRXKB=`expr $ALLRXKB + $RKBPS`
	ALLTXKB=`expr $ALLTXKB + $TKBPS`

        if [ $RXPPS -gt 5 -o $TXPPS -gt 5 ] ; then 
	    echo `date` -------------
            echo "tx $1: $TKBPS Kb/s , $TXPPS pkts/s"
            echo "rx $1: $RKBPS Kb/s , $RXPPS pkts/s"
	    echo "ALLTXP $ALLTXP , ALLRXP $ALLRXP , ALLTXKB $ALLTXKB KB , ALLRXKB $ALLRXKB KB"
	fi
done
