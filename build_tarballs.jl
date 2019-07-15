# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "RADAR5Builder"
version = v"0.0.1"

# Collection of sources required to build RADAR5Builder
sources = [
    "http://www.unige.ch/~hairer/radar5-v2.1.tar" =>
    "23b3b0152724b120b8d588b7dd1cd18428fe246e0c6fac886226009851e5138f",

]

# Bash recipe for building across all platforms
script = raw"""
cd "$WORKSPACE/srcdir/RADAR5-V2.1"

# On Windows move the library to `bin`.
if [[ ${target} == *-mingw32 ]]
then
    libdir="bin"
else
    libdir="lib"
fi

mkdir -p "${prefix}/${libdir}"

if [[ ${nbits} == 32 ]]
then
    echo "*** 32-bit BUILD ***"
    ${FC} ${LDFLAGS} -shared -fPIC -O3 -o "${prefix}/${libdir}/libradar5.${dlext}" radar5.f dc_decdel.f decsol.f contr5.f
else
    echo "*** 64-bit BUILD ***"
    ${FC} ${LDFLAGS} -shared -fPIC -fdefault-integer-8 -O3 -o "${prefix}/${libdir}/libradar5.${dlext}" radar5.f dc_decdel.f decsol.f contr5.f
fi

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]
platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libradar5", :libradar5)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

