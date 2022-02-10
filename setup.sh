#!/bin/sh
sudo modprobe loop
sudo pacman -S --noconfirm --needed artools iso-profiles
ln -sf "$(pwd)/artixiso/artools-workspace" ~/
ln -sf "$(pwd)/config/artools" ~/.config/
