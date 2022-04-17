#!/bin/sh
sudo modprobe loop

sudo pacman -Syyu --noconfirm
sudo pacman -S --noconfirm --needed artools iso-profiles archlinux-keyring archlinux-mirrorlist

sudo pacman-key --init
sudo pacman-key --populate

ln -sf "$(pwd)/artixiso/artools-workspace" ~/
ln -sf "$(pwd)/config/artools" ~/.config/
