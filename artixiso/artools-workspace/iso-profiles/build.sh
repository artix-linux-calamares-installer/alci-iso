#!/usr/bin/env bash

non_root_user=artix # since makepkg doesn't run as root, we need a non root user for aur package building ( make sure the user has no password )
#init=dinit
#init=openrc
init=runit
#init=s6
#init=suite66

## paths
chroot_dir="/var/lib/artools/buildiso/base/artix/rootfs"

## Set color characters
_set_color() {
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

## Show an INFO message
_msg_info() {
    local _subject="${1}"
    local _msg="${2}"
    printf '%s[%s] INFO: %s\n' "${YELLOW}${BOLD}" "${_subject}" "${RESET}${BOLD}${_msg}${RESET}"
}

## Customize installation.
_make_customize_chroot() {
    _msg_info "Running customize_chroot.sh in '${chroot_dir}' chroot..."
    chmod +x "${chroot_dir}/root/customize_chroot.sh"
    artix-chroot "${chroot_dir}" "/root/customize_chroot.sh"
    rm -f "${chroot_dir}/root/customize_chroot.sh"
    _msg_info "Done! customize_chroot.sh run successfully..."
}

_set_color
trap "" EXIT
buildiso -i $init -p base -x

## Update System
_msg_info "ARTIX-CHROOT" "Live environment pacman system update & populate keyring..."
artix-chroot ${chroot_dir} bash -c "pacman-key --init; pacman-key --populate artix;pacman-key --populate archlinux; pacman -Syy"

_msg_info "AUR_BUILD" "Reading package list."
for package in $(cat ./AUR_PACKAGES | grep -vE "^#.*$")
do
  _msg_info "AUR_BUILD" "Cloning ${package}."
  artix-chroot ${chroot_dir} \
	  git clone https://aur.archlinux.org/${package}.git /etc/aur_building/$package
done

_msg_info "AUR_BUILD" "Building packages"
artix-chroot ${chroot_dir} bash -c "chmod 777 -R /etc/aur_building"
dirs=$(artix-chroot ${chroot_dir} find /etc/aur_building -mindepth 1 -maxdepth 1 -type d)
for dir in $dirs
do
	artix-chroot ${chroot_dir} bash -c "cd $dir; sudo -u $non_root_user makepkg -sfci --noconfirm --needed"
done

if [[ $(artix-chroot ${chroot_dir} pacman -Qtdq) != "" ]];then
    artix-chroot ${chroot_dir} \ 
		yes | sudo pacman -Rns $(pacman -Qtdq)
    printf "\u001b[31mPACMAN:\033[0m Orphans found and removed, exiting script.\n"
    _msg_info "PACMAN" "Orphans found and removed, exiting script."
else 
    _msg_info "PACMAN" "No orphans found, exiting script."
fi
rm -rf /etc/aur_building

## Check if `customize_chroot.sh` exists.
if [[ -e $(pwd)/base/root-overlay/root/customize_chroot.sh ]]; then
    _make_customize_chroot
fi

buildiso -i $init -p base -sc
buildiso -i $init -p base -bc
buildiso -i $init -p base -zc
