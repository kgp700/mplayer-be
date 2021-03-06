#!/bin/bash
# Build script for The Fraunhofer FDK AAC Codec Library for Android
# Copyright (c) 2014 Gianluigi Tiesi <sherpya@netfarm.it>
# See LICENSE for licensing informations

GIT_REPO="git://github.com/mstorsjo/fdk-aac.git"

. $(dirname $0)/../functions.sh

BUILDDIR=fdk-aac
STATICLIBS="libfdk-aac"
CONFOPTS="--enable-shared"

PACKAGE="../dist/libfdk-aac-${ARCH}-$(cd fdk-aac && git describe --tags).7z"
HEADERS="libAACdec/include/aacdecoder_lib.h \
    libAACenc/include/aacenc_lib.h \
    libSYS/include/FDK_audio.h \
    libSYS/include/genericStds.h \
    libSYS/include/machine_type.h"

export_toolchain

save_function pkg_configure do_pkg_configure
pkg_configure()
{
    mkdir -p ../dist
    test -e ${PACKAGE} && return 0
    do_pkg_configure $*
}

make_binary_dist()
{
    test -e ${PACKAGE} && return 0
    
    echo "Building binary package..."
    make ${MAKEOPTS} || return 1

    rm -fr ../dist/${ARCH}
    install -d ../dist/${ARCH}
    ${STRIP} .libs/libfdk-aac-1.dll
    install -m 644 .libs/libfdk-aac-1.dll ../dist/${ARCH}
    unix2dos -n NOTICE ../dist/${ARCH}/NOTICE.txt

    ( cd ../dist && 7z a -mx=9 ${PACKAGE} ${ARCH} && rm -fr ${ARCH} )
}

pkg_make_target()
{
    make_binary_dist || return 1

    echo "Installing headers"
    install -d -m755 ${PREFIX}/include/fdk-aac
    for header in $HEADERS; do
        install -m644 $header ${PREFIX}/include/fdk-aac
    done
}

git_clean && pkg_build && git_clean
