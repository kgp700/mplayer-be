#!/bin/bash
# Build script for XAVS - Audio Video Standard of China
# Copyright (c) 2013-2014 Gianluigi Tiesi <sherpya@netfarm.it>
# See LICENSE for licensing informations

SVN_REPO="https://svn.code.sf.net/p/xavs/code/trunk"

. $(dirname $0)/../functions.sh

BUILDDIR=xavs

export_toolchain

pkg_make_target()
{
    make ${MAKEOPTS} libxavs.a
    install -m644 libxavs.a ${PREFIX}/lib/libxavs.a
    install -m644 xavs.h ${PREFIX}/include/xavs.h
    install -m644 xavs.pc ${PREFIX}/lib/pkgconfig/xavs.pc
}

distclean && pkg_build && distclean
