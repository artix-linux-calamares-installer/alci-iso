#!/bin/sh
sudo modprobe loop
sudo pacman -S --noconfirm --needed artools iso-profiles
sudo pacman -S --noconfirm --needed virtualbox virtualbox-host-dkms
sudo modprobe vboxdrv
ln -sf "$(pwd)/artixiso/artools-workspace" ~/
ln -sf "$(pwd)/config/artools" ~/.config/
