#!/bin/sh


if [ $# -eq 2 ]
  then
    docker run --privileged --rm -v `pwd`:/mnt debian:8 /mnt/$0 - build $1 | docker import - $2
elif [ $# -eq 3 ] && [ "$1" = "-"  ]; then
    export DEBIAN_FRONTEND=noninteractive
    export TERM=linux
        
    if [ $2 = "build" ]; then
        1>&2 $0 - prepare $3 &&\
        tar -C target -c .

    elif [ "$2" = "prepare" ]; then
        apt-get update && apt-get install -y debootstrap &&\
        debootstrap --keyring=/usr/share/keyrings/debian-archive-removed-keys.gpg $3 target http://archive.debian.org/debian &&\
        cp -a $0 target/debian-docker-image.sh &&\
        chroot target /bin/sh -c "apt-get update &&\
        apt-get upgrade &&\
        /debian-docker-image.sh - clean $3" &&\
        rm target/debian-docker-image.sh

    elif [ "$2" = "clean" ]; then
        $0 - autoclean -
        dpkg --purge --force-remove-essential sysvinit initscripts e2fsprogs e2fslibs mount util-linux sysvinit-utils
        rm /var/cache/apt/*.bin
        rm -rf /var/lib/apt/lists/archive.debian.org_*
        apt-get clean

    elif [ "$2" = "autoclean" ]; then
        1>/dev/null 2>/dev/null $0 - autoclean-recu -

    elif [ "$2" = "autoclean-recu" ]; then
        BEFORE=`dpkg -l | wc -l`        
        dpkg --get-selections | grep -Ev '^apt$' | cut -f1 | xargs -n 1 dpkg --purge
        AFTER=`dpkg -l | wc -l`
        if [ $AFTER -lt $BEFORE ]; then
            $0 - autoclean-recu -
        fi

    else
        exec $0
    fi
else
    echo
    echo "Syntax: ./debian-docker-image.sh DIST REPO"
    echo
    echo "i.e. : ./debian-docker-image.sh etch rbarazzutti/debian:4"
    echo
fi