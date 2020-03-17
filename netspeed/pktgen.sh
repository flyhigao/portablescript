#! /bin/sh
# $1 Rate in packets per s
# $2 Number of CPUs to use
# $3 packet count
# $4 srcip
# $5 dstip
# $6 dst mac
# $7 use nic
# $8 packetsize

#time sh pktgen.sh 0 2 10000000  9.9.9.1 9.9.9.2  a4:bf:01:13:9d:0a ens802f0 60
#time sh pktgen.sh 0 2 10000000  192.168.60.2 10.5.10.2  52:54:00:d9:f7:ea ens802f1 60
modprobe pktgen
function pgset() {
    local result
    if [ "$1" != "rem_device_all" ];then
        echo $1
    fi
    echo $1 > $PGDEV
}

# Config Start Here -----------------------------------------------------------
echo ratep:$1  , cpus:$2 , total count:$3 , srcip:$4 , dstip:$5 , dstmac:$6 , nic:$7 , packetsize:$8
# thread config
CPUS=$2
PKTS=`echo "scale=0; $3/$CPUS" | bc`
CLONE_SKB="clone_skb 1000"   #every 1000 packet are same
PKT_SIZE="pkt_size $8"
COUNT="count $PKTS"
DELAY="delay 0"
#DSTMAC="52:54:00:d9:f7:ea"
#ETH="ens802f1"
SRCIP=$4
DSTIP=$5
DSTMAC=$6
ETH=$7


RATEP=`echo "scale=0; $1/$CPUS" | bc`

for processor in {0..31}
do
PGDEV=/proc/net/pktgen/kpktgend_$processor
#  echo "Removing all devices"
 pgset "rem_device_all"
done


for ((processor=0;processor<$CPUS;processor++))
do
PGDEV=/proc/net/pktgen/kpktgend_$processor
#  echo "Adding $ETH"
 pgset "add_device $ETH@$processor"
 
PGDEV=/proc/net/pktgen/$ETH@$processor
#  echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "flag QUEUE_MAP_CPU"
 pgset "flag UDPCSUM"
 pgset "flag NODE ALLOC"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"
 if [ "$RATEP"x != "0"x ];then
    pgset "ratep $RATEP"
 fi
 pgset "dst $DSTIP" 
 pgset "src_min $SRCIP"
 pgset "udp_dst_min 53"
 #pgset "udp_src_min 124"
 pgset "dst_mac $DSTMAC"
 # Random address with in the min-max range
# pgset "flag IPDST_RND"
# pgset "dst_min 10.0.0.0"
# pgset "dst_max 10.255.255.255"
# enable configuration packet
# pgset "config 1"
 pgset "flows 1024"
 pgset "flowlen 8"
done

# Time to run
PGDEV=/proc/net/pktgen/pgctrl

 echo "Running... ctrl^C to stop"
 pgset "start" 
 echo "Done"

grep -h pps /proc/net/pktgen/$ETH*
