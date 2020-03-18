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

R1=`cat /sys/class/net/$1/statistics/rx_packets`
T1=`cat /sys/class/net/$1/statistics/tx_packets`
R1b=`cat /sys/class/net/$1/statistics/rx_bytes`
T1b=`cat /sys/class/net/$1/statistics/tx_bytes`         

R1_begin=$R1
T1_begin=$T1
R1b_begin=$R1b
T1b_begin=$T1b

echo beging counting ...
while true
do
        R1_old=$R1
        T1_old=$T1
        R1b_old=$R1b
        T1b_old=$T1b
        sleep 1
        R1=`cat /sys/class/net/$1/statistics/rx_packets`
        T1=`cat /sys/class/net/$1/statistics/tx_packets`
        R1b=`cat /sys/class/net/$1/statistics/rx_bytes`
        T1b=`cat /sys/class/net/$1/statistics/tx_bytes`

        TXPPS=`expr $T1 - $T1_old`
        RXPPS=`expr $R1 - $R1_old`


        TBPS=`expr $T1b - $T1b_old`
        RBPS=`expr $R1b - $R1b_old`
        TKBPS=`expr $TBPS / 128`
        RKBPS=`expr $RBPS / 128`

        if [ $RXPPS -gt 5 -o $TXPPS -gt 5 ] ; then 
                #show all diff
                Rdiff=`expr $R1 - $R1_begin`
                Tdiff=`expr $T1 - $T1_begin`
                Rbdiff=`expr $R1b - $R1b_begin`
                Tbdiff=`expr $T1b - $T1b_begin`
                RKbpsdiff=`expr $Rbdiff / 128`
                TKbpsdiff=`expr $Tbdiff / 128`

                echo `date` -------------
                echo "tx $1: $TKBPS Kb/s (ALL: $TKbpsdiff kb) , $TXPPS pkts/s (ALL: $Tdiff)"
                echo "rx $1: $RKBPS Kb/s (ALL: $RKbpsdiff kb) , $RXPPS pkts/s (ALL: $Rdiff)"

	fi
done

