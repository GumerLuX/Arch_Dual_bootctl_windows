#!/bin/bash

loadkeys es
timedatectl set-ntp true
timedatectl status
lsblk
fdisk -l
pause
mkfs.fat -F32 /dev/sda1

mkswap /dev/sda3
swapon /dev/sda3
sleep 2

mkfs.ext4 /dev/sda2
sleep 2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

reflector --country France --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel nano linux linux-firmware

pacstrap /mnt networkmanager dhcpcd netctl wpa_supplicant nano git neofetch --noconfirm

genfstab -pU /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 2
echo "sinlux" > /mnt/etc/hostname

echo -e "127.0.0.1       localhost\n::1             localhost\n127.0.0.1       $PC.localhost     $PC" > /mnt/etc/hosts
cat /mnt/etc/hosts
sleep 2
arch-chroot /mnt ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime

sed -i "/"es_ES".UTF/s/^#//g" /mnt/etc/locale.gen
echo LANG="es".UTF-8 > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen
echo KEYMAP="es" > /mnt/etc/vconsole.conf
cat /mnt/etc/vconsole.conf
sleep 2

arch-chroot /mnt  hwclock --systohc

arch-chroot /mnt mkinitcpio -P

arch-chroot /mnt bootctl --path=/boot install
		echo -e "default  arch\ntimeout  5\neditor  0" > /mnt/boot/loader/loader.conf
		partuuid=$(blkid -s PARTUUID -o value /dev/sda2)
		echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=PARTUUID=$partuuid rw" > /mnt/boot/loader/entries/arch.conf
  print_info "Comprobando el archico loader.conf"
		cat /mnt/boot/loader/loader.conf
		sleep 3
  print_info "Comprobando el archivo arch.conf"
		cat /mnt/boot/loader/entries/arch.conf
		sleep 3

arch-chroot /mnt passwd

echo -e "Escribe tu nombre de usuario:"
read usuario
arch-chroot /mnt useradd -m "$usuario"
arch-chroot /mnt passwd "$usuario"
sleep 2

cp -R "$(pwd)" ~/"$usuario"
ls ~/
chown "$usuario" ~/Arch_Dual_bootctl_windows

umount -R /mnt
umount -R /mnt/boot