#!/bin/sh
sudo modprobe loop
sudo pacman -S --noconfirm --needed artools iso-profiles
ln -sf "$(pwd)/artools-workspace" ~/
ln -sf "$(pwd)/artools" ~/.config/
