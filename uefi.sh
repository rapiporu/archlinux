#/bin/bash
timedatectl set-ntp true
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux-zen linux-firmware neovim networkmanager dhcpcd wpa_supplicant grub efibootmgr git
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
