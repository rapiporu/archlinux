#/bin/bash
sed -i '/#ParallelDownloads\ =\ 5/c\ParallelDownloads\ =\ 10' /etc/pacman.conf
#sed -i '/#VerbosePkgLists/c\VerbosePkgLists' /etc/pacman.conf
sed -i '/#Color/c\Color' /etc/pacman.conf
#echo -e "ILoveCandy\n" >> /etc/pacman.conf
timedatectl set-ntp true
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux-zen linux-firmware neovim networkmanager dhcpcd wpa_supplicant grub efibootmgr git sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
