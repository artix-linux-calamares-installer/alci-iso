#!/usr/bin/env bash

non_root_user=artix # since makepkg doesn't run as root, we need a non root user for aur package building ( make sure the user has no password )
init=runit
#init=dinit
#init=s6
#init=suite66
#init=openrc

trap "" EXIT
buildiso -i $init -p base -x

artix-chroot /var/lib/artools/buildiso/base/artix/rootfs bash -c "pacman-key --init; pacman-key --populate artix;pacman-key --populate archlinux; pacman -Syy"

printf "\033[1;33mAUR_BUILD:\033[0m Reading package list.\n"
for package in $(cat ./AUR_PACKAGES | grep -vE "^#.*$")
do
  printf "\033[1;33mAUR_BUILD:\033[0m Cloning ${package}.\n"
  artix-chroot /var/lib/artools/buildiso/base/artix/rootfs \
	  git clone https://aur.archlinux.org/${package}.git /etc/aur_building/$package
done

printf "\033[1;33mAUR_BUILD:\033[0m Building packages.\n"

artix-chroot /var/lib/artools/buildiso/base/artix/rootfs chmod 777 -R /etc/aur_building/paru-bin
dirs=$(artix-chroot /var/lib/artools/buildiso/base/artix/rootfs find /etc/aur_building -mindepth 1 -maxdepth 1 -type d)
for dir in $dirs
do
	artix-chroot /var/lib/artools/buildiso/base/artix/rootfs bash -c "cd $dir; sudo -u $non_root_user makepkg -sfci --noconfirm --needed"
done

if [[ $(artix-chroot /var/lib/artools/buildiso/base/artix/rootfs pacman -Qtdq) != "" ]];then
    artix-chroot /var/lib/artools/buildiso/base/artix/rootfs \ 
		yes | sudo pacman -Rns $(pacman -Qtdq)
    printf "\u001b[31mPACMAN:\033[0m Orphans found and removed, exiting script.\n"
else 
    printf "\u001b[31mPACMAN:\033[0m No orphans found, exiting script.\n"
fi
rm -rf /etc/aur_building

buildiso -i $init -p base -sc
buildiso -i $init -p base -bc
buildiso -i $init -p base -zc
