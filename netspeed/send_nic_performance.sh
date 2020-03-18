echo "sender_nic is $1"
ethtool -C $1 adaptive-rx off
ethtool -C $1 adaptive-tx off
ethtool -K $1 tso off
ethtool -K $1 gro off
ethtool -K $1 lro off
ethtool -K $1 gso off
ethtool -K $1 rx off
ethtool -K $1 tx off
ethtool -A $1 autoneg off
ethtool -A $1 tx off rx off 
ethtool -r $1
ethtool -a $1
