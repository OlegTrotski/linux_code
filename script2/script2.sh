#!/bin/bash

read -p "Enter the computer name: " comp_name

read -p "Create a new password for root: " comp_pass

echo -e "List of the file systems: \n1. ext2 \n2. ext3 \n.3.ext4"
read -p "Select number: " FC_num
i=0
while [ $i == 0 ]
do
	case $FC_num in
		1)
			FC=ext2
			break;;
			
		2)
			FC=ext3
			break;;
		3)
			FC=ext4
			break;;
		*)
			read -p "Uncorrect! Please, enter just numbers: " FC_num ;;
	esac
done

echo -e "List of the sections: \n1. sda1 \n2. sda2 \n3. sda3"
read -p "Select number: " case_section_num
while [ $i == 0 ]
do
	case $case_section_num in
		1)
			SECTION=sda1
			SECTION_NUM=1
			break;;
		2)
			SECTION=sda2
			SECTION_NUM=2
			break;;
		3)
			SECTION=sda3
			SECTION_NUM=3
			break;;
		*)
			read -p "Uncorrect Please, enter just number: " case_section_num ;;

		esac
	done

	echo "Create a new user"
	read -p "Enter username: " username
	read -p "Enter password: " password

	echo -e "List of display managers: \n1. SDDM \n2. LXDM \n3. XDM"
	read -e "Select number: " display_manager

	while [ $1 == 0 ]
	do 
		if [[ !$display_manager =~ ^[1-3]+$ ]] ;
		then
			echo "Please, enter just number"
			read -p "Select number: " display manager
		else
			break;
		fi
	done

	echo -e "List of desktop environments: \n1. GNOME \n2. LXDE\n3. XFCE"
	read -p "Select number" desktop_env
	
	while [ $i == 0 ]
	do
		if [[ !desktop_env =~ ^[1-3]+$ ]] ;
		then
			echo "Please, enter just numbers: "
			read -p "Select number " desktop_env
		else
			break;
		fi
	done
	

	echo "Installation was beginning"
	
	path="/dev/sda"
	sed -e 's/\s*\([\+0-9a-zA-Z]*\).-/\1/' << EOF | fdisk $path
n
p
#section_num
2048

w
e
EOF

mkfs.$FC /dev/$section
mount /dev/$section /mnt
pacstrap /mnt base linux linux-firmware base-devel
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Europe/Tallinn /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
arch-chroot /mnt /bin/bash -c "yes | pacman -S vim nano networkmanager grub"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "sed -i s/'#en_US.UTF-8'/'en_US_UTF-8'/g /etc/locale.gen"
arch-chroot /mnt /bin/bash -c "locale-gen"
arch-chroot /mnt /bin/bash -c "echo '$comp_name' > /etc/hostname"
arch-chroot /mnt /bin/bash -c "mkinitcpio -P"
echo "root:$comp_pass" | arch-chroot /mnt chpasswd
arch-chroot /mnt /bin/bash -c "grub-install /dev/sda"
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
arch-chroot /mnt /bin/bash -c "useradd -m $username -g root -p $(openssl passwd -crypt $password) -s /bin/bash"
arch-chroot /mnt /bin/bash -c "pacman -Syu"
arch-chroot /mnt /bin/bash -c "pacman -S xorg xorg-xinit mesa --noconfirm"

case $display_manager in
	1)
		arch-chroot /mnt /bin/bash -c "pacman -S sddm-kcm --noconfirm"
		arch-chroot /mnt /bin/bash -c "systemctl enable sddm";;
	2)
		arch-chroot /mnt /bin/bash -c "pacman -S lxdm --noconfirm"
		arch-chroot /mnt /bin/bash -c "systemctl enable lxdm";;
	3)
		arch-chroot /mnt /bin/bash -c "pacman -S xorg-xdm --noconfirm"
		arch-chroot /mnt /bin/bash -c "systemctl enable xdm";;
esac

case $desktop_env in
	1)
		arch-chroot /mnt /bin/bash -c "pacman -S gnome gnome -extra --noconfirm";;
	2)
		arch-chroot /mnt /bin/bash -c "pacman -S lxde_common lxsession openbox --noconfirm";;
	3)
		arch-chroot /mnt /bin/bash -c "pacman -S xfce4 --noconfirm";;
esac
reboot
