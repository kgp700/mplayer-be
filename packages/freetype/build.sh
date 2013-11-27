#!/bin/bash
# Build script for FreeType library
# Copyright (c) 2013 Gianluigi Tiesi <sherpya@netfarm.it>
# See LICENSE for licensing informations

PACKAGE=freetype
VERSION=2.5.1
EXT=tar.bz2
BASEURL=http://downloads.sourceforge.net/project/${PACKAGE}/freetype2/${VERSION}

. $(dirname $0)/../functions.sh

depends lib/libz.a
depends lib/libbz2.a
depends lib/libpng.a

STATICLIBS="libfreetype"

export LIBPNG_CFLAGS="$(${PREFIX}/bin/libpng-config --cflags)"
export LIBPNG_LDFLAGS="$(${PREFIX}/bin/libpng-config --ldflags)"

pkg_build && pkg_clean
