# run iwctl

device list
station <device> scan
station <device> get-networks
station <device> connect <SSID>

# key-map
ls /usr/share/kbd/keymaps/**/*.map.gz
loadkeys <key-name>

# set timezone
timedatectl --list-timezones
timedatectl --set-timezone <timezone>
timedatectl set-ntp true
timedatectl status

# disk-management
fdisk -l
fdisk <disk>
    : g
    : n
        : 1
        : <Enter>
        : +550M
    : n
        : 2
        : <Enter>
        : 8G
    : n
        : 3
        : <Enter>
        : <Enter>
    : t
        : 1
        : 1
    : t
        : 2
        : 19
    : w

mkfs.fat -F32 <efi>
mkswap <swap>
swapon <swap>
mkfs.ext4 <linux-filesystem>
mount <linux-filesystem> /mnt

# installing base pkgs
pacstrap /mnt base linux-lts linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/<REGION>/<CITY> /etc/localtime

hwclock --systohc

pacman -S neovim

nvim /etc/locale.gen
en_US.UTF-8 UTF-8 #
locale-gen


nvim /etc/hostname
hostname

nvim /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   <hostname>.localdomain      <hostname>


passwd

useradd -m <name>
passwd <name>

usermod -aG wheel,audio,video,storage,optical,<name> <name>

pacman -S sudo

EDITOR=nvim visudo

pacman -S grub efibootmgr dosfstools os-prober mtools


mkdir /boot/EFI
mount /dev/<efi> /boot/EFI

grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

grub-mkconfig -o /boot/grub/grub.cfg

pacman -S iwd iw wireless_tools wpa_supplicant nm-connection-editor networkmanager neovim git

systemctl enable NetworkManager

umount -l /mnt

reboot
