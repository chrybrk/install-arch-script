input=""

function getValue()
{
   echo $(python save.py $1 $2)
}

function setValue()
{
    python save.py $1 $2 $3
}

function takeInput()
{
    echo ""
    echo -n "$1> "
    read input
}

function Network()
{
	iwctl device list
    takeInput "Device"
    setValue "Network" "dev" $input
	iwctl station $(getValue "Network" "dev") scan
	iwctl station $(getValue "Network" "dev") get-networks
    takeInput "ssid"
    setValue "Network" "ssid" $input
    takeInput "pass"
    setValue "Network" "pass" $input
	iwctl --passphrase $(getValue "Network" "pass") station $(getValue "Network" "dev") connect $(getValue "Network" "ssid")
}

function KeyMapping()
{
	ls /usr/share/kbd/keymaps/**/*.map.gz | less
    takeInput "Keymap"
    setValue "Keymap" "keymap" $input
	loadkeys $(getValue "Keymap" "keymap")
}

function Timezone()
{
	timedatectl list-timezones
    takeInput "Timzone"
    setValue "Timezone" "timezone" $input
	timedatectl set-timezone $(getValue "Timezone" "timezone")
	timedatectl set-ntp true
	timedatectl status
}

function Disk()
{
	fdisk -l
    takeInput "Disk"
    setValue "Disk" "disk" $input
	fdisk $(getValue "Disk" "disk")
	clear

    takeInput "EFI"
    setValue "Disk" "efi" $input
    
    takeInput "swap"
    setValue "Disk" "swap" $input

    takeInput "Linux Filesystem"
    setValue "Disk" "rootfs" $input


	mkfs.fat -F32 $(getValue "Disk" "efi")
	mkswap $(getValue "Disk" "swap")
	swapon $(getValue "Disk" "swap")
	mkfs.ext4 $(getValue "Disk" "rootfs")
	mount $(getValue "Disk" "rootfs") /mnt
}

function BaseInstallation()
{
	pacstrap /mnt base linux-lts linux-firmware

	genfstab -U /mnt >> /mnt/etc/fstab
    echo "run ./install-arch/install.sh"
	cp ~/install-arch/ /mnt -r
	arch-chroot /mnt
}

function ZoneInfo()
{
	ls /usr/share/zoneinfo/

    takeInput "Region"
    setValue "Zone" "region" $input

	ls /usr/share/zoneinfo/$(getValue "Zone" "region")/

    takeInput "City"
    setValue "Zone" "city" $input

	ln -sf /usr/share/zoneinfo/$(getValue "Zone" "region")/$(getValue "Zone" "city")/etc/localtime

	hwclock --systohc

	pacman -S neovim
	neovim /etc/locale.gen
	locale-gen
}

function User()
{
    takeInput "Hostname"
    setValue "User" "hostname" $input

	touch /etc/hostname
	echo $(getValue "User" "hostname") > /etc/hostname

	echo "
	127.0.0.1   localhost
	::1         localhost
	127.0.0.1   $(getValue "User" "hostname").localdomain   $(getValue "User" "hostname")
	" > /etc/hosts

	echo "Root Password: "
	passwd

    takeInput "Hostname"
    setValue "User" "user" $input

	useradd -m $(getValue "User" "user")

	echo "$(getValue "User" "user")password: "
	passwd $(getValue "User" "user")

	usermod -aG wheel,audio,video,storage,optical,$(getValue "User" "user") $(getValue "User" "user")
}

function Install()
{
	pacman -S sudo grub efibootmgr dosfstools os-prober mtools

	mkdir /boot/EFI
	mount /dev/$(getValue "Disk" "efi") /boot/EFI

	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
	grub-mkconfig -o /boot/grub/grub.cfg

	pacman -S iwd iw wireless_tools wpa_supplicant nm-connection-editor networkmanager neovim git geany xorg xorg-xinit xorg-server i3 xf86-video-intel thunar nitrogen picom git gcc python python-pip dmenu xfce4-terminal xfce4-settings firefox base-devel nodejs npm

	systemctl enable NetworkManager

	EDITOR=nvim visudo
}

function menu()
{
    clear

	echo "==========================="
	echo "[Arch base linux installer]"
	echo "==========================="

	echo "1) Network"
	echo "2) Keymap"
	echo "3) Timezone"
	echo "4) Disk"
	echo "5) Base Install"
	echo "6) Zone Info"
	echo "7) User setup"
	echo "8) Install"
    echo "9) Auto Install"
	echo "0) Reboot"

    takeInput @

	if [[ $input == "1" ]]; then
        Network
        menu
	elif [[ $input == "2" ]]; then
        KeyMapping
        menu
	elif [[ $input == "3" ]]; then
		Timezone
		menu
	elif [[ $input == "4" ]]; then
		Disk
		menu
	elif [[ $input == "5" ]]; then
		BaseInstallation
		menu
	elif [[ $input == "6" ]]; then
		ZoneInfo
		menu
	elif [[ $input == "7" ]]; then
		User
		menu
	elif [[ $input == "8" ]]; then
		Install
		menu
	elif [[ $input == "0" ]]; then
		umount -l /mnt
		reboot
	fi
}


menu