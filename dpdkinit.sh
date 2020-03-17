if ! cat /boot/grub2/grub.cfg | grep hugepages ;then
    cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg`date +%s` -rf
	sed -i "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 default_hugepagesz=1G hugepagesz=1G hugepages=2 iommu=pt intel_iommu=on isolcpus=0,8,16,24\"/" /etc/default/grub
	grub2-mkconfig -o /boot/grub2/grub.cfg	

    
#begin allocate hugepage
    cat > /usr/lib/systemd/system/hugetlb-gigantic-pages.service <<EOF
[Unit]
Description=HugeTLB Gigantic Pages Reservation
DefaultDependencies=no
Before=dev-hugepages.mount
ConditionPathExists=/sys/devices/system/node
ConditionKernelCommandLine=hugepagesz=1G

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/lib/systemd/hugetlb-reserve-pages.sh

[Install]
WantedBy=sysinit.target
EOF
    cat > /usr/lib/systemd/hugetlb-reserve-pages.sh <<'EOF'
#!/bin/sh

nodes_path=/sys/devices/system/node/
if [ ! -d $nodes_path ]; then
        echo "ERROR: $nodes_path does not exist"
        exit 1
fi

reserve_pages()
{
        echo $1 > $nodes_path/$2/hugepages/hugepages-1048576kB/nr_hugepages
}

reserve_pages 2 node0
reserve_pages 2 node1
#if   Cause: Creation of mbuf pool for socket 1 failed: Cannot allocate memory  then need to increse reserve_pages 2 nodex
#if 2 cpu then node1 and node1 must use
EOF
chmod +x /usr/lib/systemd/hugetlb-reserve-pages.sh

#Enable early boot reservation:
systemctl enable hugetlb-gigantic-pages
#end allocate hugepage

fi
cat >> ~/.bashrc <<EOF
export RTE_SDK=/mnt/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
EOF

cat >> /etc/rc.local <<EOF
export RTE_SDK=/mnt/dpdk
export RTE_TARGET=x86_64-native-linuxapp-gcc
EOF
