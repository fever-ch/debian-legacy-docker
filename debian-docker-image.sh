#!/bin/sh

if [ $# -eq 2 ]
  then
    docker run --privileged --rm -v `pwd`:/mnt debian:8 /mnt/$0 - build $1 | docker import - $2
elif [ $# -eq 3 ] && [ "$1" = "-"  ]; then
    if [ $2 = "build" ]; then
        1>&2 $0 - prepare $3 &&\
        tar -C target -c .
    elif [ "$2" = "prepare" ]; then
        export DEBIAN_FRONTEND=noninteractive
        export TERM=linux
        apt-get update && apt-get install -y debootstrap &&\
        debootstrap --keyring=/usr/share/keyrings/debian-archive-removed-keys.gpg $3 target http://archive.debian.org/debian &&\
        chroot target /bin/sh -c "apt-get update &&\
        apt-get upgrade &&\
        apt-get clean &&\
        dpkg --purge dhcp3-client dhcp3-common ifupdown netbase manpages man-db info laptop-detect tasksel tasksel-data logrotate cron adduser wget procps iptables vim-tiny vim-common netcat openbsd-inetd update-inetd nano iputils-ping whiptail traceroute tcpd libnewt0.52 groff-base net-tools dmidecode "
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