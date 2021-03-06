#!/bin/bash
# Build script for x265 H.265/MPEG-H HEVC Encoder
# Copyright (c) 2014 Gianluigi Tiesi <sherpya@netfarm.it>
# See LICENSE for licensing informations

HG_REPO="http://hg.videolan.org/x265"

. $(dirname $0)/../functions.sh

BUILDDIR=x265
BUILDSUBDIR=source

CMAKE=1
CMAKEOPTS=" \
    -DENABLE_SHARED=0 \
    -DENABLE_CLI=0"

hg_clean && pkg_build && hg_clean
