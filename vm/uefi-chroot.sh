#!/bin/bash
ln -sf /usr/share/zoneinfo/America/Buenos_Aires /etc/localtime
hwclock --systohc
sed -i '/#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8' /etc/locale.gen
sed -i '/#es_AR.UTF-8 UTF-8/c\es_AR.UTF-8 UTF-8' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo archlinux > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 archlinux.localdomain archlinux" | sudo tee /etc/hosts > /dev/null
mkinitcpio -p linux-zen
passwd
useradd -mG wheel user
passwd user
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
exit
