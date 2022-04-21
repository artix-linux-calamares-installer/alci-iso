# Dockerfile for building the Artix ISO
FROM gabrielmatthews/artix-base

RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm --needed artools iso-profiles archlinux-keyring archlinux-mirrorlist 

RUN pacman-key --init
RUN pacman-key --populate

WORKDIR /artix-iso
COPY . .

RUN mkdir -p ~/.config
RUN ln -sf "$(pwd)/artixiso/artools-workspace" ~/
RUN ln -sf "$(pwd)/config/artools" ~/.config/

CMD cd /root/artools-workspace/iso-profiles ; ./build.sh
