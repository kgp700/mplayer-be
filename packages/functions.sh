# vim: ft=sh

. $(dirname $0)/../../config.sh

shopt -s nullglob

MAKEOPTS=-j$(cat /proc/cpuinfo | grep "^processor" | wc -l)
FILENAME=${PACKAGE}-${VERSION}.${EXT}
BUILDDIR=${PACKAGE}-${VERSION}

case ${HOST} in
    i?86-*-mingw32) GLOBAL_CFLAGS="-O2 -mtune=generic -march=i486" ;;
    x86_64-*-mingw32) GLOBAL_CFLAGS="-O2 -mtune=generic -march=x86-64" ;;
esac

sanity_check()
{
    for dir in bin include lib; do
        if [ ! -d ${PREFIX}/$dir ]; then
            echo "${PREFIX}/$dir is not a directory"
            exit 1
        fi
        if [ ! -w ${PREFIX}/$dir ]; then
            echo "${PREFIX}/$dir is not writable"
            exit 1
        fi
    done
}
sanity_check

depends()
{
    if [ ! -e "${PREFIX}/$1" ]; then
        echo "Missing dependency $1"
        exit 1
    fi
}

do_single_target()
{
    MAKEFILES=$(find ${BUILDDIR} -name Makefile)
    for makefile in ${MAKEFILES}; do
        grep -q $1 $makefile && ( cd $(dirname $makefile) && make $1)
    done
}

pkg_download()
{
    test -f ${FILENAME} || wget -c -O ${FILENAME} ${BASEURL}/${FILENAME}
}

pkg_unpack()
{
    test -z ${BASEURL} && return
    test -d ${FILENAME} || pkg_download

    case ${FILENAME} in
        *.tar.xz)
            decomp=J
            ;;
        *.tar.bz2)
            decomp=j
            ;;
        *.tar.gz)
            decomp=z
            ;;
    esac

    rm -fr ${BUILDDIR}
    tar -$decomp -xf ${FILENAME}
}

pkg_configure()
{
    test -x configure || return 0

    CFLAGS="${GLOBAL_CFLAGS} ${CFLAGS}"     \
    CXXFLAGS="${GLOBAL_CFLAGS} ${CFLAGS}"   \
    ./configure             \
        --host=${HOST}      \
        --prefix=${PREFIX}  \
        --enable-static     \
        --disable-shared    \
        --disable-nls       \
        ${CONFOPTS} || return 1
}

pkg_make_target()
{
    make ${MAKEOPTS} install || return 1
}

apply_patches()
{
    for p in patches/*; do
        patch -p0 -N < $p
    done
}

make_ld_script()
{
    eval $(grep dependency_libs= $1)
    eval $(grep old_library= $1)
    libname="${old_library:3:-2}_s"

    LIBS=""
    for lib in $dependency_libs; do
        case $lib in
            -L*) ;;
            -lm) ;;
            -lc) ;;
            -l*) LIBS="${LIBS} $lib" ;;
        esac
    done

    test -z "${LIBS}" && return

    echo "GROUP ( -l${libname}${LIBS} )"
}

fix_la()
{
    test -z "${STATICLIBS}" && return

    for lib in ${STATICLIBS}; do

        lib_a=${PREFIX}/lib/${lib}.a
        lib_s=${PREFIX}/lib/${lib}_s.a
        lib_la=${PREFIX}/lib/${lib}.la

        test -e $lib_la || continue
        echo "Fixing static lib $lib..."
        rm -f $lib_s

        LDSCRIPT=$(make_ld_script $lib_la)
        rm -f $lib_la

        test -e $lib_a || continue
        test -z "${LDSCRIPT}" && continue

        mv -f $lib_a $lib_s
        echo ${LDSCRIPT} > $lib_a

    done
}

ln_to_cp()
{
    # ln -s -> cp -f
    find . -type f -name Makefile -exec sed -i -e 's/ln -s/cp -f/g' {} \;
}

pkg_build()
{
    pkg_unpack || return 1
    apply_patches || return 1

    ( cd ${BUILDDIR} && pkg_configure ) || return 1
    ( cd ${BUILDDIR} && ln_to_cp )
    ( cd ${BUILDDIR} && pkg_make_target ) || return 1

    fix_la
}

git_clean()
{
    ( cd ${BUILDDIR} && git clean -dfx )
}

distclean()
{
    ( cd ${BUILDDIR} && ( make distclean > /dev/null 2>&1 || true ) )
}

pkg_clean()
{
    rm -fr ${BUILDDIR}
}
