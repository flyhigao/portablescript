echo "sender_nic is $1"
ethtool -C $1 adaptive-rx off
ethtool -K $1 tso off
ethtool -K $1 gro off
ethtool -K $1 lro off
ethtool -K $1 gso off
ethtool -K $1 rx off
ethtool -K $1 tx off
