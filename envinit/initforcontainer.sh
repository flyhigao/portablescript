unalias cp
yum groupinstall -y "Development Tools" -y
yum install git net-tools  wget openssl-devel bzip2-devel zlib zlib-devel   ansible curl yum-utils  jq rsync which psmisc numactl numactl-devel kernel-devel libpcap-devel  sysstat sysfsutils  ntp tcpdump -y
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime -rf
