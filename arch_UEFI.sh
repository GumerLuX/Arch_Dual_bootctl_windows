#!/bin/bash
#Version:0.1 
#Scrip de instalacion d Arch Linux con Windows, utilizando la particion boot de Windows existente.

if [[ -f $(pwd)/estilos ]]; then
	source estilos
else
	echo "missing file: estilos"
	exit 1
fi

setfont ter-132b

select_wifi() {
	write_header "Configuracion de la red WIFI https://gumerlux.github.io/Blog.GumerLuX/"
	print_info "Tenemos que obtener los datos de nuestra red wifi"
	echo -e "Buscando los dispositivos de red"
	sleep 1
	# Este es nuestro DEVICE
	#ip addr | grep "wlp\|wlo\|wlan" | awk '{print $2}' | sed 's/://' | head -n 1
	DEVICE=$(ip addr | grep "wlp\|wlo\|wlan" | awk '{print $2}' | sed 's/://' | head -n 1)
	echo -e   "Esta es tu station DEVICE: "[${Red} $DEVICE ${fin}]
	# Obteniendo nuestro SSID
	# nmcli dev wifi list | grep -v "SSID" | tr "*" " "
	# SSID=$(nmcli dev wifi list | grep -v "SSID" | tr "*" " " | awk '{print $2}' | head -1)
	iwlist scanning | grep ESSID
	print_info "Anota tu Red:"
	read ESSID
	echo -e   "Esta es tu Nombre SSID: "[${Red} $ESSID ${fin}]
	print_info "Si todo es correcto escribe tu contraseña."
	print_line
	read -p "Pon tu contraseña ej(SC9VRsiT): " PASSPHRASE
	pause_function
	iwctl --passphrase=$PASSPHRASE station $DEVICE connect $ESSID
	if ping -c1 google.com &>/dev/null;
		then
				WIFI="Estas conectado";
				echo "Estas conectado";
		else
				WIFI="No tienes conexion";
				echo "No tienes conexion";
	fi
	}

select_keymap() {
	write_header "SELECCION KEYMAP Y LOCALES - https://gumerlux.github.io/Blog.GumerLuX/"
	print_info "La variable KEYMAP se especifica en el archivo /etc/rc.conf. Define qué mapa de teclas es el teclado en las consolas virtuales.\n* Consultar lista de codigos, para otras regiones del pais:
	1- Lista idiomas: https://es.wikipedia.org/wiki/ISO_639-1#Tabla_de_c%C3%B3digos_asignados_o_reservados
	2- Locales: https://docs.oracle.com/cd/E26921_01/html/E27143/glset.html"
	cat keyboard | column
	echo -e "$purple(*)$blue Ingresa el codigo de tu teclado ej: ${Yellow}[${Green} es ${fin}${Yellow}]$green$fin "
	read KEYMAP
}
configure_locale(){
  write_header "SELECCION DE LOCALES - https://gumerlux.github.io/Blog.GumerLuX/"
  cat keyboard | column
  echo -e "$purple(*)$blue Ingresa el codigo de tus Locales ej: ${Yellow}[${Green} es_ES ${fin}${Yellow}]$green$fin "
  read LOCALE
}
configure_zona_horaria(){
  write_header "ZONA HORARIA - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "Escoge tu zona horaria de la lista.\nRespeta las mayúsculas ej: Europe"
  echo
  find /usr/share/zoneinfo -maxdepth 1 -type d | sed -n -e 's!^.*/!!p' | grep "${ZONE}" | sort | column
  echo
  read ZONE
  pause_function
  write_header "ZONA HORARIA - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "Escoge tu localización horaria de la lista.\nRespeta las mayúsculas ej: Madrid"
  echo
  ls /usr/share/zoneinfo/"$ZONE"
  echo
  read SUBZONE
}

configure_mirrorlist(){
	write_header "Configuramos los mirrors mas rapidos de ArchLinux"
	print_info "Hay varias manera de actualizar los mirrorlist:\nUsaremos reflector ycon dos posivilidades"
	sleep 1
	echo -e "1. ${Yellow}Los 10 servidores mas rapidos de todos${fin}"
	sleep 1
	echo -e "2. ${Yellow}los 10 servidores mas rapidos de un pais${fin}"
	sleep 1
	echo -e "${Gray}Elija una opción ej: '1'${fin}"
	echo
	read MIRRORLIST

		if [ "$MIRRORLIST" = "1" ]
			then
			reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
		elif [ "$MIRRORLIST" = "2" ]
			then
			print_info "Escoge tu pais de preferencia ej: 'Francia'"
			sleep 1
			reflector --list-countries | column
			echo -e "$purple(*)$blue Tu pais es:${fin}"
			read PAIS_mirror
			print_info "Escoge el codigo de tu pais de preferencia ej: (FR) para 'Francia'"
			echo -e "$purple(*)$blue Tu codigo es:${fin}"
			read CODE_mirror
			reflector --country ${CODE_mirror} --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
		fi
}

configure_hostname(){
  write_header "Elegimos el nombre de nuestra máquina 'hostname' - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "Tenemos que poner un nombre a nuestro PC o MAQUINA.\n  Nos sirve para identificarlo cuando estamos conectados por RED."
  print_info "El hostname de tu PC es:"
  read host_name
  echo
  pause_function
}

configure_disco(){
	write_header "Vamos a preparar el disco para la instalacion en modo UEFI"
	print_info "Hacemos esta instalacion junto con Windows, utilizaremos la particion boot de windows 'Sistema EFI'\nNormalmente esta en '/dev/sda1'\nUtilizaremos el espacio continuo, creando una particion para root y una para swap"
	echo -e "1- Identificamos el disco y lo anotamos.\n2- Anotamos la particion boot de windows.\n3- Creamos la partición del sistema / 'root'\n4- Creamos la partición swap\n
	Comprovamos nuestro disco"
	pause_function

	write_header "Comprovamos las particiones que tenemos en modo UEFI"
	fdisk -l
	print_info "Cual es es disco donde creamos las particiones ej: [${Yellow}sda${fin}]"
	read DISCO
	print_line

	write_header "Creacion de particiones"
	cfdisk /dev/${DISCO}

	write_header "Creadas las particiones vamos a anotar nuestros discos para la instalacion en modo UEFI"
	fdisk -l /dev/$DISCO
	print_info "Cual es tu particion 'boot' ej: [${Yellow}sda1${fin}] "
	read BOOT

	write_header "Creadas las particiones vamos a anotar nuestros discos para la instalacion en modo UEFI"
	fdisk -l /dev/$DISCO
	print_info "Cual es tu particion 'root' ej: [${Yellow}sda4${fin}]"
	read ROOT

	write_header "Creadas las particiones vamos a anotar nuestros discos para la instalacion en modo UEFI"
	fdisk -l /dev/$DISCO
	print_info "Cual es tu particion 'swap' ej: [${Yellow}sda5${fin}]"
	read SWAP
	pause_function
}

sistema(){
  write_header "SISTEMA BASE - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "  Elegimos el sistema base a instalar. Tenemos 4º opciones para elegir:"
  echo
  echo -e "   1.La${Yellow} Estable ${fin}— Versión vainilla.${Blue} Recomendado${fin}"
  echo -e "   2.La${Yellow} Hardened ${fin}— Enfocado en la seguridad"
  echo -e "   3.La${Yellow} LTS ${fin}— De larga duración,${Blue} para PCs. antiguos${fin}"
  echo -e "   4.La${Yellow} Kernel ZEN ${fin}— Kernel mejorado, por hackers.${Blue} Recomendado ${fin}"
  echo
  echo -e "${Gray} Eleja una opción ej: '1'${fin}"
  echo
  read sistema
  echo
  pause_function
}

insatall_arch(){
	write_header "Enpezando la instalacion"
	print_info "Configurado el script de instlacion preparamos el sistema para la instalación"
	# Añadiendo memoria al sistema
		mount -o remount,size=2G /run/archiso/cowspace
		sleep 2
	#1-Idioma
	write_header "Poniendo el teclado en tu idioma"
		loadkeys "$KEYMAP"
		sleep 2
	#2-Formateando particiones root y swap
	write_header "Dar formato a las particiones"
		mkfs.ext4 -L arch /dev/"$ROOT"
		mkswap -L swap /dev/"$SWAP"
		swapon /dev/"$SWAP"
		sleep 3
	#3-Montando particiones
	write_header "Montando las particiones creadas"
		mount /dev/"$ROOT" /mnt
		mkdir -p /mnt/boot
		mount /dev/"$BOOT" /mnt/boot
		sleep 3
	#4-Instalando sistema Base
	write_header "Instalando el sistema base"
		    if [ "$sistema" = "1" ]
        then
      pacstrap -i /mnt base base-devel linux linux-firmware linux-headers--noconfirm
    elif [ "$sistema" = "2" ]
        then
            pacstrap /mnt base base-devel linux linux-hardened linux-hardened-headers linux-firmware --noconfirm
    elif [ "$sistema" = "3" ]
        then
            pacstrap /mnt base base-devel linux linux-lts linux-lts-headers linux-firmware--noconfirm
    elif [ "$sistema" = "4" ]
        then
            pacstrap /mnt base base-devel linux linux-zen linux-zen-headers linux-firmware --noconfirm
    fi
	pause_function
	#5-CONFIGURANDO EL SISTEMA
	write_header "Estamos configurando el sistema"
	print_info "Anadiendo extras y conplementos para el sistema"
		pacstrap /mnt ntfs-3g nfs-utils gvfs gvfs-afc gvfs-mtp espeakup networkmanager dhcpcd netctl s-nail openresolv wpa_supplicant xdg-user-dirs nano vi git gpm jfsutils logrotate usbutils neofetch --noconfirm
		sleep 2
		genfstab -pU /mnt >> /mnt/etc/fstab
		cat /mnt/etc/fstab
		sleep 2
		echo "$host_name" > /mnt/etc/hostname
	write_header "Configurando el hosts"
		echo -e "127.0.0.1       localhost\n::1             localhost\n127.0.0.1       $PC.localhost     $PC" > /mnt/etc/hosts
		cat /mnt/etc/hosts
		sleep 2
	write_header "Configurando la Zona Horaria"
		arch-chroot /mnt ln -s /usr/share/zoneinfo/"$ZONE"/"$SUBZONE" /etc/localtime
	write_header "Configurando Idioma y locales"
		sed -i "/"$LOCALE".UTF/s/^#//g" /mnt/etc/locale.gen
		echo LANG="$LOCALE".UTF-8 > /mnt/etc/locale.conf
		arch-chroot /mnt locale-gen
		echo KEYMAP="$idioma" > /mnt/etc/vconsole.conf
		cat /mnt/etc/vconsole.conf
		sleep 2
	write_header "Actualizando la hora en el sistema"
		arch-chroot /mnt hwclock -w
	pause_function

	#6-INSTALACION system-boot - UEFI
	write_header "INSTALACION systen-boot - UEFI - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "  Vamos a instalar el cargador de arranque bootctl.\nPues vamos a ello y continuemos."
  pause_function
		arch-chroot /mnt bootctl --path=/boot install
		echo -e "default  arch\ntimeout  5\neditor  0" > /mnt/boot/loader/loader.conf
		partuuid=$(blkid -s PARTUUID -o value /dev/"$root")
		echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=PARTUUID=$partuuid rw" > /mnt/boot/loader/entries/arch.conf
  print_info "Comprobando el archico loader.conf"
		cat /mnt/boot/loader/loader.conf
		sleep 5
  print_info "Comprobando el archivo arch.conf"
		cat /mnt/boot/loader/entries/arch.conf
		sleep 3
  pause_function
	#7-CONTRASEÑA ROOT
	write_header "CONTRASEÑA ROOT - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "  Elegimos una contraseña de administrador 'root'.
    Es una cuenta de superusuario nos provee de todos los privilegios del sistema
    Para entrar en sistema:
    user = root + password"
  echo
  echo -e "${Yellow} Escribe tu contraseña: ${fin}"
  echo
  # Password root
  arch-chroot /mnt passwd
  echo
  pause_function
	#8-CREAR CUENTA DE USUARIO y CONTRASEÑA
  write_header "CREAR CUENTA DE USUARIO - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "  Creamos la cuenta de usuario.
    Es la cuenta que nos da acceso a nuestros archivos, directorios y periféricos del sistema
    Para entrar en sistema:
    usuario + password"
		echo
		echo -e "${Yellow} Escribe tu nombre de usuario: ${fin}"
		echo
		read usuario
  # Crear usuario
  arch-chroot /mnt useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash "$usuario"
  sleep 2
  print_info "  Elegimos la contraseña de nuestro usuario.
    Para entrar en sistema:
    user + password"
  pause_function
  # Contraseña de usuario
		arch-chroot /mnt passwd "$usuario"
  pause_function
  #9-FIN DE INSTALACION
  write_header "INSTALACION COMPLETADA - https://gumerlux.github.io/Blog.GumerLuX/"
  print_info "Se copiará el script instalacion en el directorio / root de su nuevo sistema"
  pause_function
  echo
		cp -rp /root/Arch_Dual_bootctl_windows /mnt/root/Arch_Dual_bootctl_windows
		echo
  print_info "Desmontando particiones"
  pause_function
		echo
		umount -R /mnt
		echo
  print_info "Reiniciando el sistema"
  pause_function
	# BYE
		echo -e "\n\nBBBBBB  YY    YY EEEEEEE"
		echo        "BB  BBB  YY YY   EE     "
		echo        "BB  BBB   YYY    EE     "
		echo        "BBBBBB    YYY    EEEEEE "
		echo        "BB  BBB   YYY    EE     "
		echo        "BB  BBB   YYY    EE     "
		echo -e     "BBBBBB    YYY    EEEEEEE\n\n"
		sleep 2s
		reboot
}


while true; do
	write_header " - https://gumerlux.github.io/Blog.GumerLuX/"
	echo " 1) $(mainmenu_item "${checklist[1]}" "Activamos Wifi" "${WIFI}")"
	echo " 2) $(mainmenu_item "${checklist[2]}" "Idioma del teclado" "${KEYMAP}")"
	echo " 3) $(mainmenu_item "${checklist[3]}" "Configuramos Locales" "${LOCALE}")"
	echo " 4) $(mainmenu_item "${checklist[4]}" "Elegimos Zona horaria" "${ZONE}/${SUBZONE}")"
	echo " 5) $(mainmenu_item "${checklist[5]}" "Configuramos Mirrorlist" "(${PAIS_mirror}) / (${CODE_mirror})")"
	echo " 6) $(mainmenu_item "${checklist[6]}" "Configuramos Nombre PC" "${host_name}")"
	echo " 7) $(mainmenu_item "${checklist[7]}" "Configuracion del Disco" "(/${DISCO}) p_boot (/${BOOT}) p_root (/${ROOT}) p_swap (/${SWAP})")"
	echo " 8) $(mainmenu_item "${checklist[8]}" "Eligiendo el sistema" "${sistema}")"
	echo " 9) $(mainmenu_item "${checklist[9]}" "Iniciamos la Instalacion" )"
	echo ""
	echo " d) Salir Instalacion"
	echo ""
	read_input_options
	for OPT in "${OPTIONS[@]}"; do
		case "$OPT" in
		1)
			select_wifi
			checklist[1]=1
			;;
		2)
			select_keymap
			checklist[2]=1
			;;
		3)
			configure_locale
			checklist[3]=1
			;;
		4)
			configure_zona_horaria
			checklist[4]=1
			;;
		5)
			configure_mirrorlist
			checklist[5]=1
			;;
		6)
			configure_hostname
			checklist[6]=1
			;;
		7)
			configure_disco
			checklist[7]=1
			;;
		8)
			sistema
			checklist[8]=1
			;;
		9)
			insatall_arch
			checklist[9]=1
			;;
		"d")
			exit
			;;
		*)
			invalid_option
			;;
		esac
	done
done
#}}}
