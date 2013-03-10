#!/bin/sh
while read package; do
    pushd $package > /dev/null

    echo -n "Building $package..."
    ./build.sh > /dev/null 2>&1

    if [ $? -gt 0 ]; then
         echo "failed"
         exit 1
    fi
    echo "ok"

    popd >/dev/null
done << EOF
winpthreads
dlfcn-win32
zlib
bzip2
libiconv
enca
expat
faac
freetype
libpng
fontconfig
fribidi
gavl
frei0r
lame
regex
libcddb
libcdio
libcdio-paranoia
libbs2b
libmodplug
libass
libregif
libcaca
libdca
libgsm
libilbc
libjpeg-turbo
libmad
libogg
libvorbis
libtheora
libsoxr
speex
opus
flac
libvpx
live555
lzo
opencore-amr
libsdl
twolame
x264
xavs
xvidcore
EOF
