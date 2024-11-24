#!/bin/bash

if [[ -f $(pwd)/estilos ]]; then
	source estilos
else
	echo "missing file: estilos"
	exit 1
fi

write_header "Necesitamos saber unos parametros para realizarla instalacion"
print_info "El mombre de tu PC"
read host_name
print_info "El mombre de usuario"
read usuario
pause_function

write_header "Configurarcion del disco"
print_info "Con cfdisk creamos tres particiones\n1 para boot\n2 para sistema root\3 para intercambio swap"
cfdisk
write_header "Con estos datos podemos enpezar la instalacion, comprobando"
pause_function

print_info "Formatemos la paricion boot"
fdisk -l
mkfs.fat -F32 /dev/sda1

print_info "Formatemos la paricion swap y montamos"
mkswap /dev/sda3
swapon /dev/sda3

print_info "Formatemos la paricion root"
mkfs.ext4 /dev/sda2
pause_function

print "Montamos las particiones root y boot"
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
lsblk
print_info "Ya tenemos el disco preparado para la instalacion, empezemos"
pause_function

timedatectl set-ntp true
timedatectl status

pacstrap /mnt base base-devel nano linux linux-firmware

pacstrap /mnt networkmanager dhcpcd netctl wpa_supplicant nano git neofetch --noconfirm

genfstab -pU /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 2
echo "$host_name" > /mnt/etc/hostname

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

pause_function

print_info "Creando contraseña root"
arch-chroot /mnt passwd

arch-chroot /mnt useradd -m "$usuario"

print_info "Creando contraseña usuario"
arch-chroot /mnt passwd "$usuario"
sleep 2
pause_function

cp -R "$(pwd)" ~/"$usuario"
ls ~/
chown "$usuario" ~/Arch_Dual_bootctl_windows

umount -R /mnt
umount -R /mnt/boot