#!/bin/bash
#post-up
IFACE=$1
for i in rx tx sg tso ufo gso gro lro rxvlan txvlan nocache copy sg rxhash; do ethtool -K $IFACE $i off; done
ethtool -L $IFACE combined 1
ethtool -G $IFACE rx 4096 tx 4096
ifconfig $IFACE mtu 9000
ifconfig $IFACE promisc
systemctl stop irqbalance >/dev/null 2>&1
pkill irqbalance >/dev/null 2>&1


