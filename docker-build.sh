#!/bin/sh

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

## Change ownership variables.
_user=`echo ${SUDO_USER:-$(whoami)}`
_gid=`echo ${SUDO_GID}`
_group=`cat /etc/group | grep ${_gid} | cut -d: -f1 | head -1`

## iso Paths and file
_build="$(pwd)/build/"
_output="$(pwd)/Artix-Iso/"

## iso filename format
_name="artix-runit"
_version="$(date +%Y.%m.%d)"
_arch="x86_64"
_iso_filename="${_name}-${_version}-${_arch}.iso"

_finalize_build() {
  local _file=$(find ${_build} -type f -name "*iso")

  ## Change iso filename to current format
  echo "+---------------------->>"
  echo "[*] Move Iso '$(basename ${_file})' as '${_iso_filename}'..."
  mkdir -p ${_output}
  find ${_build} -type f -name "*.iso" -exec mv {} ${_output}${_iso_filename} \;

  ## Change ownership
  echo "+---------------------->>"
  echo "[*] Change ${_output} ownership to '${_user}'..."
  chown -R ${_user}:${_group} ${_output}

  ## Remove empty build directory
  rm -rf ./build
}

## Delete existing Artix-Iso directory from home user
echo "+---------------------->>"
echo "[*] Delete existing ${_output}..."
if [[ -d ${_output} ]]; then
  rm -rf ${_output}
fi

## Build Docker Image
docker build -t artix-build ./

if [ "$?" -ne 0 ]; then
    exit 1
fi

## Run The Docker Image
mkdir -p ${_build} ./pacman-cache
docker run --privileged \
           --mount type=bind,source="$(pwd)"/build,target=/root/artools-workspace/iso \
           --mount type=bind,source="$(pwd)"/pacman-cache,target=/var/cache/pacman/pkg \
           -t artix-build &&\
           _finalize_build
