#!/bin/bash
#
moban=moban7
read -p "虚拟机名称：" name
create (){
qemu-img create -f qcow2 -b /var/lib/libvirt/images/${moban}.qcow2 /var/lib/libvirt/images/$name.img &>/dev/null
virsh dumpxml $moban > /etc/libvirt/qemu/${name}.xml
}
define () {
sed -i '/<uuid>/d' /etc/libvirt/qemu/${name}.xml
sed -i '/mac address/d' /etc/libvirt/qemu/${name}.xml
sed -i "s/"$moban"/"$name"/g" /etc/libvirt/qemu/${name}.xml
sed -i "s/"$name".qcow2/"$name".img/g" /etc/libvirt/qemu/${name}.xml
virsh define /etc/libvirt/qemu/${name}.xml &>/dev/null
}
guest () {
mkdir /mnt/$name
guestmount -a /var/lib/libvirt/images/$name.img -i /mnt/$name
echo " " >/mnt/$name/etc/udev/rules.d/70-persistent-net.rules
sed -i "/UUID/d" /mnt/$name/etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/HWADDR/d" /mnt/$name/etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/ONBOOT/cONBOOT="yes"' /mnt/$name/etc/sysconfig/network-scripts/ifcfg-eth0
sync
umount /mnt/$name
rm -rf /mnt/$name
}

create
define
guest

[ $? = 0 ]  && echo "$name 添加成功！！" || echo "$name 添加失败！！"
