#!/bin/bash
# Build script for vid.stab - Transcode video stabilization plugin
# Copyright (c) 2014 Gianluigi Tiesi <sherpya@netfarm.it>
# See LICENSE for licensing informations

GIT_REPO="git://github.com/georgmartius/vid.stab.git"

. $(dirname $0)/../functions.sh

BUILDDIR=vid.stab

CMAKE=1
CMAKEOPTS=" \
    -DBUILD_SHARED_LIBS=0"

git_clean && pkg_build && git_clean
