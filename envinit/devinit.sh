#this script will install normal dev env
#https://gitlab.codet.net:1443/yuhang/noclouds/raw/dev/EXTRA/dev_env/initsetup.sh
#below http://192.168.0.87:2015/ could be replace with http://ddns.codet.net:52015/
HTTPSRVIP='192.168.0.87:2015'
needupdaterepo=0
installfrom=local
installvagrant_kvm=1
systemctl stop NetworkManager
if ! grep "dns=none" /etc/NetworkManager/NetworkManager.conf ; then
     sed -i '/\[main\]/adns=none' /etc/NetworkManager/NetworkManager.conf
fi
systemctl restart NetworkManager
if ! grep 114.114.114.114 /etc/resolv.conf ;then
cat >> /etc/resolv.conf << EOF
nameserver 114.114.114.114
EOF
fi 

if [ $needupdaterepo -eq 1 ];then
    cp /etc/yum.repos.d/ /etc/yum.repos.dbak -rf
    #rm /etc/yum.repos.d/* -rf
    yum install curl -y
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo    

cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1systemctl stop NetworkManager
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
    #sed -i   's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf 
    yum clean all
    yum makecache -y
fi 
##install from net
if [ $installfrom == 'local' ];then
    Yumoption='--enablerepo=gaorepo1'
cat > /etc/yum.repos.d/gaorepo1.repo << EOF
[gaorepo1]
name=This is a local repo
baseurl=http://${HTTPSRVIP}/rpm/
enabled=1
gpgcheck=0
EOF
    yum clean all
    yum makecache
fi
echo Yumoption is $Yumoption ==================
yum groups mark install "Development Tools" -y $Yumoption
yum groups mark convert "Development Tools" -y $Yumoption
yum groupinstall -y "Development Tools" -y $Yumoption
yum install git net-tools tcpreplay bridge-utils wget openssl-devel bzip2-devel zlib \
    zlib-devel qemu libvirt-devel libxslt-devellibffi-devel python36-pip ansible curl \
    qemu-kvm libvirt libvirt-python libguestfs-tools virt-install bridge-utils \
    yum-utils device-mapper-persistent-data lvm2 docker-ce jq rsync which  psmisc  numactl numactl-devel kernel-devel libpcap-devel jq sysstat sysfsutils sg3_utils ntp tcpdump python-jwt python-routes -y $Yumoption
systemctl stop NetworkManager
systemctl disable NetworkManager
#timezone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime -rf
ntpdate asia.pool.ntp.org && hwclock -w

wget http://${HTTPSRVIP}/package/baiduyun/baidupcs.tgz   
tar zxvf baidupcs.tgz -C /usr/local/bin/ ; rm baidupcs.tgz -C

wget http://${HTTPSRVIP}/package/proxychain4/proxychain.tgz
tar zxvf proxychain.tgz -C /
yum -y install http://${HTTPSRVIP}/rpm/vagrant_2.2.4_x86_64.rpm
echo Make sure you change /etc/proxychains.conf last line to proper proxy!!!!!!!!!!

#增加aliyun的docker仓库
cp -n /lib/systemd/system/docker.service /etc/systemd/system/docker.service
sed -i "s|ExecStart=/usr/bin/docker daemon.*|ExecStart=/usr/bin/docker daemon --registry-mirror=https://g4yvromt.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
sed -i "s|ExecStart=/usr/bin/dockerd.*|ExecStart=/usr/bin/dockerd --registry-mirror=https://g4yvromt.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl   restart docker

#centos7默认没有启动脚本这里增加
cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=simple
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
EOF

cat >> /etc/rc.local <<EOF
##gao add rclocal
export PS1="\u@\h \W# "
sleep 10 
systemctl stop NetworkManager
ntpdate asia.pool.ntp.org && hwclock -w
touch /tmp/rclocal
EOF

chmod +x /etc/rc.local
#设置到系统启动：
systemctl enable rc-local

#启动脚本：
#systemctl start rc-local.service
systemctl daemon-reload


##below can't run in a docker container
if ! ls /.dockerenv ;then
    #关闭selinux
    sed -i 's/enforcing/disabled/' /etc/selinux/config
    setenforce 0
    #==========
    if [ $installvagrant_kvm == '1' ];then
        systemctl restart libvirtd
        systemctl enable  libvirtd  # enable kvm 
        systemctl enable  docker  # enable docker
        CONFIGURE_ARGS='with-ldflags=-L/opt/vagrant/embedded/lib with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib64' GEM_HOME=~/.vagrant.d/gems GEM_PATH=$GEM_HOME:/opt/vagrant/embedded/gems PATH=/opt/vagrant/embedded/bin:$PATH proxychains4 vagrant plugin install vagrant-libvirt
    fi
    systemctl daemon-reload

fi

