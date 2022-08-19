input=""

function takeInput()
{
	echo ""
	echo -n "$1> "
	read input
}

function getValue()
{
	echo $(python save.py $1 $2)
}

function setValue()
{
	python save.py $1 $2 $input
}

function step1()
{
	takeInput "Hostname"
	setValue "user" "hostname"
	takeInput "New User"
	setValue "user" "homeuser"
	takeInput "Region"
	setValue "user" "region"
	takeInput "City"
	setValue "user" "city"

	timedatectl set-timezone $(getValue "user" "region")/$(getValue "user" "city")
	timedatectl set-ntp true
	timedatectl status

	fdisk -l
	takeInput "Disk"
	setValue "user" "disk"
	fdisk $(getValue "user" "disk") < cmds

	mkfs.fat -F32 $(getValue "user" "disk")1
	mkswap $(getValue "user" "disk")2
	mkfs.ext4 $(getValue "user" "disk")3
	mount $(getValue "user" "disk")3 /mnt

	pacstrap /mnt base linux-lts linux-firmware

	genfstab -U /mnt >> /mnt/etc/fstab
	cp ~/install-arch/ /mnt -r
	arch-chroot /mnt
}

function step2()
{
	ln -sf /usr/share/zoneinfo/$(getValue "user" "region")/$(getValue "user" "city") /etc/localtime

	hwclock --systohc

	pacman -S neovim
	vim /etc/locale.gen
	locale-gen

	touch /etc/hostname
	echo $(getValue "user" "hostname") > /etc/hostname

	echo "
	127.0.0.1	localhost
	::1		localhost
	127.0.0.1 $(getValue "user" "hostname").localdomain 	$(getValue "user" "hostname")
	" > /etc/hosts

	echo "root pswd"
	passwd

	useradd -m $(getValue "user" "homeuser")

	echo "$(getValue "user" "homeuser") pswd"
	passwd $(getValue "user" "homeuser")

	usermod -aG wheel,audio,video,storage,optical,$(getValue "user" "homeuser") $(getValue "user" "homeuser")

	pacman -S sudo grub efibootmgr dosfstools os-prober mtools

	mkdir /boot/EFI
	mount $(getValue "user" "disk")1 /boot/EFI
	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
	grub-mkconfig -o /boot/grub/grub.cfg

	pacman -S iwd iw wireless_tools wpa_supplicant nm-connection-editor networkmanager neovim git base-devel

	systemctl enable NetworkManager

	EDITOR=nvim visudo
}

echo "Step 1: Base Installation"
echo "Step 2: Final Installation"

takeInput "Option"

if [[ $input == "1" ]]; then
	step1
elif [[ $input == "2" ]]; then
	step2
fi
