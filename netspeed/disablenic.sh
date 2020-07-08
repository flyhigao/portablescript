#post-up 
IFACE=$1
for i in rx tx sg tso ufo gso gro lro rxvlan txvlan nocache copy sg rxhash; do ethtool -K $IFACE $i off; done 
ethtool -L $IFACE combined 1
ifconfig $IFACE mtu 9000
systemctl stop irqbalance
systemctl disable irqbalance


