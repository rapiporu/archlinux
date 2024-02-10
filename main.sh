#!/bin/bash
R='\033[0;31m'
B='\033[0;34m'
G='\033[0;32m'
O='\033[0;33m'
P='\033[0;35m'
C='\033[0;36m'
LG='\033[0;37m'
DG='\033[1;30m'
LR='\033[1;31m'
Y='\033[1;33m'
NC='\033[0m'

install1() {
    echo "Don't be silly."
    ping -c 2 google.com > /dev/null
    if [$? -ne 0]; then
    echo "There is not Internet"
    break
    fi
    timedatectl set-ntp true
    cryptsetup luksFormat /dev/$DISK\2
    cryptsetup luksOpen /dev/$DISK\2 root
    pvcreate /dev/mapper/root
    vgcreate vg /dev/mapper/root
    echo -n "Root space: "; read rootspace
    lvcreate -L $rootspace\G vg -n root
    lvcreate -l 100%FREE vg -n home
    mkfs.ext4 /dev/vg/root
    mkfs.ext4 /dev/vg/home
    mkfs.fat -F32 /dev/sda1
    mount /dev/vg/root /mnt
    mkdir /mnt/{home,boot}
    mount /dev/vg/home /mnt/home
    mount /dev/sda1 /mnt/boot
    pacstrap /mnt base linux-zen linux-firmware neovim lvm2 networkmanager dhcpcd wpa_supplicant grub efibootmgr amd-ucode git
    genfstab -U /mnt >> /mnt/etc/fstab
    echo $R\D$B\o$Y\n$C\e$O\!
    echo "Remember to execute \"arch-chroot /mnt\" and do the user installation"
}

install2() {
    ln -sf /usr/share/zoneinfo/America/Buenos_Aires /etc/localtime
    hwclock --systohc
    sed -i '/#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8' /etc/locale.gen
    sed -i '/#es_AR.UTF-8 UTF-8/c\es_AR.UTF-8 UTF-8' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    echo archlinux > /etc/hostname
    echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 archlinux.localdomain archlinux" | sudo tee /etc/hosts > /dev/null
    sed -i '/HOOKS=(base udev autodetect modconf block filesystems fsck)/c\HOOKS=(base udev autodetect keyboard modconf block encrypt lvm2 filesystems fsck)' /etc/mkinitcpio.conf
    mkinitcpio -p linux-zen
    passwd
    echo -n "User: "; read $FUTUREUSER
    useradd -m -G wheel $FUTUREUSER
    passwd $FUTUREUSER
    sed -i '/GRUB_CMDLINE_LINUX=""/c\GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:lvm root=/dev/vg/root"' /etc/default/grub
    grub-install --target=x86_64-efi --efi-directory=/boot
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable NetworkManager
    exit
    umount -R /mnt
    echo $R\D$B\o$Y\n$C\e$O\!
}
install3() {
    echo "$R\Installing yay...$NC"
    cd /tmp
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si
    yay -S --needed - < packages.txt
    sudo downgrade virtualbox-guest-iso
    sudo systemctl disable systemd-oomd
    sudo systemctl enable nohang
    systemctl --user start syncthing
    echo "$R\Making files and folders...$NC"
    echo 'D /tmp/"Temporary Downloads" 0700 polenta polenta' | sudo tee /usr/lib/tmpfiles.d/tmpdownloads.conf > /dev/null
    echo 'D /tmp/"Temporary Downloads 2" 0700 polenta polenta' | sudo tee /usr/lib/tmpfiles.d/tmpdownloads2.conf > /dev/null
    echo 'D /tmp/"pacmancache" 0755 root root' | sudo tee /usr/lib/tmpfiles.d/pacmancache.conf > /dev/null
    sudo mkdir /etc/sddm.conf.d
    echo -e "[General]\nDisplayServer=wayland\nGreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell\n[Wayland]\nCompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1" | sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null
    sudo systemd-tmpfiles --create
    mkdir $HOME/{Other,Sync,VMs,ISOs,Installations,Wine,Applications,Torrents,ROMs}
    mkdir $HOME/Documents/{Blender,Projects}
    mkdir $HOME/Pictures/{Krita,Screenshots,Wallpapers,pps}
    mkdir $HOME/Music/Soundpad
    mkdir $HOME/Videos/Records
    mkdir $HOME/Wine/{.premiere,.illustrator,.osu,.photoshop,.office}
    echo "$R\Configuring Wine...$NC"
    env WINEPREFIX=$HOME/Wine/.premiere winetricks -q d3dx9 riched20 msxml3 gdiplus
    env WINEPREFIX=$HOME/Wine/.photoshop winetricks -q fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk vkd3d
    env WINEPREFIX=$HOME/Wine/.illustrator winetricks -q corefonts fontsmooth=rgb gdiplus atmlib msxml3 msxml6
    env WINEPREFIX=$HOME/Wine/.osu winetricks -q dotnet48 cjkfonts corefonts meiryo vlgothic gdiplus_winxp win2k3
    cd /tmp
    wget https://m1.ppy.sh/r/osu!install.exe
    env WINEPREFIX=$HOME/Wine/.osu wine "osu!install.exe"
    echo "$R\Copying system files and config files...$NC"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo cp -f environment /etc/environment
    cp -f .zshrc $HOME/.zshrc
    cp -f .zsh_history $HOME/.zsh_history
    cp -f -r .config $HOME/.config
    sudo waydroid init
    echo $R\D$B\o$Y\n$C\e$O\!
    echo "Remember to enable secure boot."
}

main() {

echo "----------------------------"
echo "Always remember to:"
echo "Check Wifi/Ethernet."
echo "Check if UEFI is available."
echo "----------------------------"
echo "Options:"
echo "1) Install Arch Linux (Part 1)"
echo "2) Install Arch Linux (Part 2)"
echo "3) User Installation"
echo -n "> "; read choose
case $choose in
    1)
    install1
    ;;
    2)
    install2
    ;;
    3)
    install3
    ;;
    *)
    echo "What?"
    ;;
    esac
}

echo -e $R\A$B\S$G\S$O\H$LG\O$Y\L$C\E $DG\A$P\R$LR\C$O\H $LR\I$Y\N$G\S$R\T$C\A$DG\L$Y\L$G\A$C\T$DG\I$R\O$B\N$NC
main
