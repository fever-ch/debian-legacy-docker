#!/bin/sh



if [ $# -eq 2 ]; then
    if [ "$VERBOSE" = "true" ]; then
        export DBG="/dev/stderr"
    else
        export DBG="/dev/null"
    fi

    docker run --privileged --rm -v `pwd`:/mnt debian:8 /bin/sh -c "DBG=$DBG /mnt/$0  - build $1" | docker import - $2 && echo "Image ready"

elif [ $# -eq 3 ] && [ "$1" = "-"  ]; then
    export DEBIAN_FRONTEND=noninteractive
    export TERM=linux
        
    if [ $2 = "build" ]; then
        1>&2 $0 - prepare $3 

        1>/dev/stderr echo "Converting system tree into docker image"
        tar -C target -c .
        
    elif [ "$2" = "prepare" ]; then
        echo "Preparing Debootstrap environmnent"
        1>$DBG 2>$DBG sh -c "apt-get update && apt-get install -y debootstrap"
        
        echo "Building Debian $3 with Debootstrap"
        1>$DBG 2>$DBG debootstrap --keyring=/usr/share/keyrings/debian-archive-removed-keys.gpg $3 target http://archive.debian.org/debian
        cp -a $0 target/debian-legacy-docker.sh &&\

        echo "Shrinking image"
        1>$DBG 2>$DBG chroot target /bin/sh -c "
        /debian-legacy-docker.sh - clean $3" &&\
        rm target/debian-legacy-docker.sh

    elif [ "$2" = "clean" ]; then
        $0 - autoclean -
        dpkg --purge --force-remove-essential sysvinit initscripts e2fsprogs e2fslibs mount util-linux sysvinit-utils
        apt-get clean
        rm -rf /var/lib/apt/lists/archive.debian.org_*

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
    echo "Syntax: ./debian-legacy-docker.sh DIST REPO"
    echo
    echo "i.e. : ./debian-legacy-docker.sh etch rbarazzutti/debian-legacy:4"
    echo
fi