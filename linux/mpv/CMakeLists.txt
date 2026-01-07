cmake_minimum_required(VERSION 3.10)
project(mpv LANGUAGES CXX)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
add_compile_options(-I${MPV_PREFIX}/include)
add_link_options(-L${MPV_LIB})

include(ExternalProject)
include(ProcessorCount)

ProcessorCount(NPROC)
if(NOT NPROC)
  set(NPROC 1)
endif()

get_filename_component(APP_SOURCE_DIR "${CMAKE_SOURCE_DIR}" DIRECTORY)
get_filename_component(APP_SOURCE_DIR "${APP_SOURCE_DIR}" DIRECTORY)
set(SUBMODULES_DIR "${APP_SOURCE_DIR}/submodules")

set(MPV_PREFIX "${CMAKE_BINARY_DIR}/prefix")
set(MPV_LIB "${MPV_PREFIX}/lib")
set(MPV_BIN "${MPV_PREFIX}/bin")
set(MPV_INCLUDE "${MPV_PREFIX}/inlcude")
set(MPV_PKGCONFIG "${MPV_LIB}/pkgconfig")

file(MAKE_DIRECTORY "${MPV_PREFIX}")

set(CFLAGS "-I${MPV_INCLUDE} -fPIC -w -Wno-everything")
set(PREFIX_ENV
  PATH=${MPV_BIN}:$ENV{PATH}
  PKG_CONFIG_PATH=${MPV_PKGCONFIG}
  PKG_CONFIG_LIBDIR=${MPV_PKGCONFIG}
  LD_LIBRARY_PATH=${MPV_LIB}
  LIBRARY_PATH=${MPV_LIB}
  C_INCLUDE_PATH=${MPV_INCLUDE}
  CPLUS_INCLUDE_PATH=${MPV_INCLUDE}
  CFLAGS=${CFLAGS}
  CXXFLAGS=${CFLAGS}
  LDFLAGS=-L${MPV_LIB}
)
set(STOPBUILD "${CMAKE_SOURCE_DIR}/stopbuild.sh")

#region fribidi
set(FRIBIDI_SOURCE_DIR "${CMAKE_BINARY_DIR}/fribidi")
set(FRIBIDI_BUILD_DIR  "${CMAKE_BINARY_DIR}/fribidi-build")
set(FRIBIDI_BYPRODUCTS ${MPV_LIB}/libfribidi.so)

ExternalProject_Add(fribidi
  GIT_REPOSITORY  https://github.com/fribidi/fribidi.git
  GIT_TAG         v1.0.8
  GIT_SHALLOW     1

  SOURCE_DIR        "${FRIBIDI_SOURCE_DIR}"
  BINARY_DIR        "${FRIBIDI_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${FRIBIDI_BYPRODUCTS}"

  CONFIGURE_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${FRIBIDI_BYPRODUCTS}
      meson setup
        "${FRIBIDI_BUILD_DIR}"
        "${FRIBIDI_SOURCE_DIR}"
        --warnlevel=0
        --prefix=${MPV_PREFIX}
        -Dc_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dcpp_link_args=-Wl,-rpath-link=${MPV_LIB}
        --libdir=lib
        -Dbuildtype=release
        -Ddocs=false
  BUILD_COMMAND     ${STOPBUILD} ${FRIBIDI_BYPRODUCTS} meson compile -C "${FRIBIDI_BUILD_DIR}"
  INSTALL_COMMAND   ${STOPBUILD} ${FRIBIDI_BYPRODUCTS} meson install -C "${FRIBIDI_BUILD_DIR}"
)
#endregion

#region opus
set(OPUS_SOURCE_DIR "${CMAKE_BINARY_DIR}/opus")
set(OPUS_BUILD_DIR  "${CMAKE_BINARY_DIR}/opus-build")
set(OPUS_BYPRODUCTS ${MPV_LIB}/libopus.so)

ExternalProject_Add(opus
  GIT_REPOSITORY  https://github.com/xiph/opus.git
  GIT_TAG         v1.5.2
  GIT_SHALLOW     1

  SOURCE_DIR        "${OPUS_SOURCE_DIR}"
  BINARY_DIR        "${OPUS_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${OPUS_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${OPUS_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${OPUS_BYPRODUCTS}
      ./autogen.sh &&
    cd "${OPUS_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${OPUS_BYPRODUCTS}
      meson setup
        "${OPUS_BUILD_DIR}"
        "${OPUS_SOURCE_DIR}"
        --warnlevel=0
        --prefix=${MPV_PREFIX}
        -Dc_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dcpp_link_args=-Wl,-rpath-link=${MPV_LIB}
        --libdir=lib
        -Dbuildtype=release
  BUILD_COMMAND     ${STOPBUILD} ${OPUS_BYPRODUCTS} meson compile -C "${OPUS_BUILD_DIR}"
  INSTALL_COMMAND   ${STOPBUILD} ${OPUS_BYPRODUCTS} meson install -C "${OPUS_BUILD_DIR}"
)
#endregion

#region ogg
set(OGG_SOURCE_DIR "${CMAKE_BINARY_DIR}/ogg")
set(OGG_BUILD_DIR  "${CMAKE_BINARY_DIR}/ogg-build")
set(OGG_BYPRODUCTS ${MPV_LIB}/libogg.so)

ExternalProject_Add(ogg
  GIT_REPOSITORY  https://github.com/xiph/ogg.git
  GIT_TAG         v1.3.6
  GIT_SHALLOW     1

  SOURCE_DIR        "${OGG_SOURCE_DIR}"
  BINARY_DIR        "${OGG_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${OGG_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${OGG_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${OGG_BYPRODUCTS}
      ./autogen.sh &&
    cd "${OGG_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${OGG_BYPRODUCTS}
      ${OGG_SOURCE_DIR}/configure
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared

  BUILD_COMMAND     ${STOPBUILD} ${OGG_BYPRODUCTS} make -C "${OGG_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${OGG_BYPRODUCTS} make -C "${OGG_BUILD_DIR}" install
)
#endregion

#region vorbis
set(VORBIS_SOURCE_DIR "${CMAKE_BINARY_DIR}/vorbis")
set(VORBIS_BUILD_DIR  "${CMAKE_BINARY_DIR}/vorbis-build")
set(VORBIS_BYPRODUCTS ${MPV_LIB}/libvorbis.so)

ExternalProject_Add(vorbis
  GIT_REPOSITORY  https://github.com/xiph/vorbis.git
  GIT_TAG         v1.3.7
  GIT_SHALLOW     1

  SOURCE_DIR        "${VORBIS_SOURCE_DIR}"
  BINARY_DIR        "${VORBIS_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${VORBIS_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${VORBIS_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${VORBIS_BYPRODUCTS}
      ./autogen.sh &&
    cd "${VORBIS_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${VORBIS_BYPRODUCTS}
      ${VORBIS_SOURCE_DIR}/configure
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared

  BUILD_COMMAND     ${STOPBUILD} ${VORBIS_BYPRODUCTS} make -C "${VORBIS_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${VORBIS_BYPRODUCTS} make -C "${VORBIS_BUILD_DIR}" install
)
#endregion

add_dependencies(vorbis ogg)

#region nasm
set(NASM_SOURCE_DIR "${CMAKE_BINARY_DIR}/nasm")
set(NASM_BUILD_DIR  "${CMAKE_BINARY_DIR}/nasm-build")
set(NASM_BYPRODUCTS ${MPV_BIN}/nasm)

ExternalProject_Add(nasm
  URL https://www.nasm.us/pub/nasm/releasebuilds/2.15/nasm-2.15.tar.xz
  URL_HASH SHA256=bc340c2604de5a9aa405b194aae3bcdd86c1631a68a5f4d2165e11d358c2c223

  SOURCE_DIR        "${NASM_SOURCE_DIR}"
  BINARY_DIR        "${NASM_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${NASM_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${NASM_SOURCE_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${NASM_BYPRODUCTS}
      ./configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}

  BUILD_COMMAND     ${STOPBUILD} ${NASM_BYPRODUCTS} make -C "${NASM_SOURCE_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${NASM_BYPRODUCTS} make -C "${NASM_SOURCE_DIR}" install
)
#endregion

#region x264
set(X264_SOURCE_DIR "${CMAKE_BINARY_DIR}/x264")
set(X264_BUILD_DIR  "${CMAKE_BINARY_DIR}/x264-build")
set(X264_BYPRODUCTS ${MPV_LIB}/libx264.so)

ExternalProject_Add(x264
  GIT_REPOSITORY  https://github.com/mirror/x264.git
  GIT_TAG         c24e06c2e184345ceb33eb20a15d1024d9fd3497
  GIT_SHALLOW     1

  SOURCE_DIR        "${X264_SOURCE_DIR}"
  BINARY_DIR        "${X264_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${X264_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${X264_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${X264_BYPRODUCTS}
      "${X264_SOURCE_DIR}/configure"
        --prefix=${MPV_PREFIX}
        --enable-shared

  BUILD_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${X264_BYPRODUCTS}
      make -C "${X264_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${X264_BYPRODUCTS} make -C "${X264_BUILD_DIR}" install
)
#endregion

add_dependencies(x264 nasm)

#region x265
set(X265_SOURCE_DIR "${CMAKE_BINARY_DIR}/x265")
set(X265_BUILD_DIR  "${CMAKE_BINARY_DIR}/x265-build")
set(X265_BYPRODUCTS ${MPV_LIB}/libx265.so)

ExternalProject_Add(x265
  GIT_REPOSITORY  https://github.com/videolan/x265.git
  GIT_TAG         3.4
  GIT_SHALLOW     1

  SOURCE_DIR        "${X265_SOURCE_DIR}"
  BINARY_DIR        "${X265_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${X265_BYPRODUCTS}"
  INSTALL_DIR       "${MPV_PREFIX}"

  CONFIGURE_COMMAND
    cd ${X265_BUILD_DIR} &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${X265_BYPRODUCTS}
      ${CMAKE_COMMAND} ${X265_SOURCE_DIR}/source
        -DCMAKE_INSTALL_PREFIX=${MPV_PREFIX}
        -DCMAKE_BUILD_TYPE=Release
        -DENABLE_SHARED=ON
        -DENABLE_STATIC=OFF
        -DENABLE_HDR10_PLUS=OFF
        -DENABLE_CLI=OFF
        -DENABLE_TESTS=OFF
        -DX265_INSTALL_PREFIX=${MPV_PREFIX}

  # x265 requires this to avoid in-tree pollution
  BUILD_COMMAND   ${STOPBUILD} ${X265_BYPRODUCTS} ${CMAKE_COMMAND} --build .
  INSTALL_COMMAND ${STOPBUILD} ${X265_BYPRODUCTS} ${CMAKE_COMMAND} --build . --target install
)
#endregion

#region libjpeg
set(LIBJPEG_SOURCE_DIR "${CMAKE_BINARY_DIR}/libjpeg")
set(LIBJPEG_BUILD_DIR  "${CMAKE_BINARY_DIR}/libjpeg-build")
set(LIBJPEG_BYPRODUCTS ${MPV_LIB}/libjpeg.so)

ExternalProject_Add(libjpeg
  GIT_REPOSITORY  https://github.com/libjpeg-turbo/libjpeg-turbo.git
  GIT_TAG         2.1.2
  GIT_SHALLOW     1

  SOURCE_DIR        "${LIBJPEG_SOURCE_DIR}"
  BINARY_DIR        "${LIBJPEG_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBJPEG_BYPRODUCTS}"
  INSTALL_DIR       "${MPV_PREFIX}"

  CONFIGURE_COMMAND
    cd ${LIBJPEG_BUILD_DIR} &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBJPEG_BYPRODUCTS}
      ${CMAKE_COMMAND} ${LIBJPEG_SOURCE_DIR}
        -DCMAKE_INSTALL_PREFIX=${MPV_PREFIX}
        -DCMAKE_BUILD_TYPE=Release
        -DENABLE_SHARED=ON
        -DENABLE_STATIC=OFF
        -DWITH_JPEG8=ON
        -DWITH_SIMD=ON
        -DENABLE_TESTS=OFF
        -DCMAKE_INSTALL_PREFIX=${MPV_PREFIX}

  BUILD_COMMAND
    ${STOPBUILD} ${LIBJPEG_BYPRODUCTS} ${CMAKE_COMMAND} --build "${LIBJPEG_BUILD_DIR}" --config Release

  INSTALL_COMMAND
    ${STOPBUILD} ${LIBJPEG_BYPRODUCTS} ${CMAKE_COMMAND} --build "${LIBJPEG_BUILD_DIR}" --target install
)
#endregion

#region libvpx
set(LIBVPX_SOURCE_DIR "${CMAKE_BINARY_DIR}/libvpx")
set(LIBVPX_BUILD_DIR  "${CMAKE_BINARY_DIR}/libvpx-build")
set(LIBVPX_BYPRODUCTS ${MPV_LIB}/libvpx.so)

ExternalProject_Add(libvpx
  GIT_REPOSITORY  https://github.com/webmproject/libvpx.git
  GIT_TAG         v1.11.0
  GIT_SHALLOW     1

  SOURCE_DIR        "${LIBVPX_SOURCE_DIR}"
  BINARY_DIR        "${LIBVPX_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBVPX_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${LIBVPX_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBVPX_BYPRODUCTS}
      ${LIBVPX_SOURCE_DIR}/configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-examples
        --disable-tools
        --disable-unit-tests

  BUILD_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBVPX_BYPRODUCTS}
      make -C "${LIBVPX_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${LIBVPX_BYPRODUCTS} make -C "${LIBVPX_BUILD_DIR}" install
)
#endregion

add_dependencies(libvpx nasm)

#region numa
set(NUMA_SOURCE_DIR "${CMAKE_BINARY_DIR}/numa")
set(NUMA_BUILD_DIR  "${CMAKE_BINARY_DIR}/numa-build")
set(NUMA_BYPRODUCTS ${MPV_LIB}/libnuma.so)

ExternalProject_Add(numa
  GIT_REPOSITORY  https://github.com/numactl/numactl.git
  GIT_TAG         v2.0.14
  GIT_SHALLOW     1

  SOURCE_DIR        "${NUMA_SOURCE_DIR}"
  BINARY_DIR        "${NUMA_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${NUMA_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${NUMA_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${NUMA_BYPRODUCTS}
      ./autogen.sh &&
    cd "${NUMA_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${NUMA_BYPRODUCTS}
      ${NUMA_SOURCE_DIR}/configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared

  BUILD_COMMAND     ${STOPBUILD} ${NUMA_BYPRODUCTS} make -C "${NUMA_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${NUMA_BYPRODUCTS} make -C "${NUMA_BUILD_DIR}" install
)
#endregion

#region gmp
set(GMP_SOURCE_DIR "${CMAKE_BINARY_DIR}/gmp")
set(GMP_BUILD_DIR  "${CMAKE_BINARY_DIR}/gmp-build")
set(GMP_BYPRODUCTS ${MPV_LIB}/libgmp.so)

ExternalProject_Add(gmp
  URL https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz
  URL_HASH SHA256=fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2

  SOURCE_DIR        "${GMP_SOURCE_DIR}"
  BINARY_DIR        "${GMP_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${GMP_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${GMP_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${GMP_BYPRODUCTS}
      ${GMP_SOURCE_DIR}/configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared

  BUILD_COMMAND     ${STOPBUILD} ${GMP_BYPRODUCTS} make -C "${GMP_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${GMP_BYPRODUCTS} make -C "${GMP_BUILD_DIR}" install
)
#endregion

#region nettle
set(NETTLE_SOURCE_DIR "${CMAKE_BINARY_DIR}/nettle")
set(NETTLE_BUILD_DIR  "${CMAKE_BINARY_DIR}/nettle-build")
set(NETTLE_BYPRODUCTS ${MPV_LIB}/libnettle.so)

ExternalProject_Add(nettle
  GIT_REPOSITORY  https://github.com/gnutls/nettle.git
  GIT_TAG         nettle_3.10.2_release_20250626
  GIT_SHALLOW     1

  SOURCE_DIR        "${NETTLE_SOURCE_DIR}"
  BINARY_DIR        "${NETTLE_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${NETTLE_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${NETTLE_SOURCE_DIR}" &&
    rm ./nettle.texinfo | true &&
    ${STOPBUILD}
      ${NETTLE_BYPRODUCTS}
      ./.bootstrap &&
    cd "${NETTLE_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${NETTLE_BYPRODUCTS}
      ${NETTLE_SOURCE_DIR}/configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-documentation

  BUILD_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD} ${NETTLE_BYPRODUCTS} make -C "${NETTLE_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${NETTLE_BYPRODUCTS} make -C "${NETTLE_BUILD_DIR}" install
)
#endregion

add_dependencies(nettle gmp)

#region gnutls
set(GNUTLS_SOURCE_DIR "${CMAKE_BINARY_DIR}/gnutls")
set(GNUTLS_BUILD_DIR  "${CMAKE_BINARY_DIR}/gnutls-build")
set(GNUTLS_BYPRODUCTS ${MPV_LIB}/libgnutls.so)

ExternalProject_Add(gnutls
  URL https://www.gnupg.org/ftp/gcrypt/gnutls/v3.7/gnutls-3.7.11.tar.xz
  URL_HASH SHA256=90e337504031ef7d3077ab1a52ca8bac9b2f72bc454c95365a1cd1e0e81e06e9

  SOURCE_DIR        "${GNUTLS_SOURCE_DIR}"
  BINARY_DIR        "${GNUTLS_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${GNUTLS_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${GNUTLS_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${GNUTLS_BYPRODUCTS}
      ${GNUTLS_SOURCE_DIR}/configure
        --libdir=${MPV_LIB}
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --with-included-libtasn1
        --with-included-unistring
        --without-p11-kit

  BUILD_COMMAND     ${STOPBUILD} ${GNUTLS_BYPRODUCTS} make -C "${GNUTLS_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${GNUTLS_BYPRODUCTS} make -C "${GNUTLS_BUILD_DIR}" install
)
#endregion

add_dependencies(gnutls nettle)

#region ffmpeg
set(FFMPEG_SOURCE_DIR "${CMAKE_BINARY_DIR}/ffmpeg")
set(FFMPEG_BUILD_DIR  "${CMAKE_BINARY_DIR}/ffmpeg-build")
set(FFMPEG_BYPRODUCTS ${MPV_BIN}/ffmpeg)

ExternalProject_Add(ffmpeg
  GIT_REPOSITORY  https://github.com/FFmpeg/FFmpeg.git
  GIT_TAG         n4.2.11
  GIT_SHALLOW     1

  SOURCE_DIR        "${FFMPEG_SOURCE_DIR}"
  BINARY_DIR        "${FFMPEG_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${FFMPEG_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd ${FFMPEG_BUILD_DIR} &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${FFMPEG_BYPRODUCTS}
      ${FFMPEG_SOURCE_DIR}/configure
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-autodetect
        --disable-doc
        --disable-htmlpages
        --disable-manpages
        --disable-podpages
        --disable-txtpages
        --disable-nvenc
        --disable-nvdec
        --disable-cuvid
        --disable-cuda
        --disable-cuda-nvcc
        --disable-libnpp
        --disable-hwaccels
        --disable-libv4l2
        --disable-v4l2-m2m
        --disable-libtheora
        --disable-postproc
        --disable-libass
        --disable-libfreetype
        --disable-libfontconfig
        --disable-openssl
        --disable-vaapi
        --disable-vdpau
        --disable-amf
        --disable-libxcb
        --disable-libxcb-shm
        --disable-libxcb-xfixes
        --disable-libxcb-shape
        --disable-xlib
        --disable-libbluray
        --disable-libcdio
        --disable-libxml2
        --disable-libzvbi
        --disable-librsvg
        --disable-libwebp
        --disable-libspeex
        --disable-libmp3lame
        --disable-libdav1d
        --enable-gpl
        --enable-libfribidi
        --enable-libvorbis
        --enable-libopus
        --enable-libvpx
        --enable-libx264
        --enable-libx265
        --enable-network
        --enable-gnutls

  BUILD_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${FFMPEG_BYPRODUCTS}
      make -C "${FFMPEG_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${FFMPEG_BYPRODUCTS} make -C "${FFMPEG_BUILD_DIR}" install
)
#endregion

add_dependencies(ffmpeg fribidi opus vorbis nasm x264 x265 libjpeg libvpx numa gmp gnutls)

#region freetype
set(FREETYPE_SOURCE_DIR "${CMAKE_BINARY_DIR}/freetype")
set(FREETYPE_BUILD_DIR  "${CMAKE_BINARY_DIR}/freetype-build")
set(FREETYPE_BYPRODUCTS ${MPV_LIB}/libfreetype.so)

ExternalProject_Add(freetype
  GIT_REPOSITORY  https://github.com/freetype/freetype.git
  GIT_TAG         VER-2-14-1
  GIT_SHALLOW     1

  SOURCE_DIR        "${FREETYPE_SOURCE_DIR}"
  BINARY_DIR        "${FREETYPE_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${FREETYPE_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${FREETYPE_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${FREETYPE_BYPRODUCTS}
      ./autogen.sh &&
    cd "${FREETYPE_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${FREETYPE_BYPRODUCTS}
      ${FREETYPE_SOURCE_DIR}/configure
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --without-png
        --without-zlib
        --without-bzip2

  BUILD_COMMAND     ${STOPBUILD} ${FREETYPE_BYPRODUCTS} make -C ${FREETYPE_BUILD_DIR} -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${FREETYPE_BYPRODUCTS} make -C ${FREETYPE_BUILD_DIR} install
)
#endregion

#region harfbuzz
set(HARFBUZZ_SOURCE_DIR "${CMAKE_BINARY_DIR}/harfbuzz")
set(HARFBUZZ_BUILD_DIR  "${CMAKE_BINARY_DIR}/harfbuzz-build")
set(HARFBUZZ_BYPRODUCTS ${MPV_LIB}/libharfbuzz.so)

ExternalProject_Add(harfbuzz
  GIT_REPOSITORY  https://github.com/harfbuzz/harfbuzz.git
  GIT_TAG         12.3.0
  GIT_SHALLOW     1

  SOURCE_DIR        "${HARFBUZZ_SOURCE_DIR}"
  BINARY_DIR        "${HARFBUZZ_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${HARFBUZZ_BYPRODUCTS}"

  CONFIGURE_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${HARFBUZZ_BYPRODUCTS}
      meson setup
        "${HARFBUZZ_BUILD_DIR}"
        "${HARFBUZZ_SOURCE_DIR}"
        --warnlevel=0
        --prefix=${MPV_PREFIX}
        --libdir=lib
        -Dc_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dcpp_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dglib=disabled
        -Dgobject=disabled
        -Dicu=disabled
        -Dtests=disabled
        -Dcairo=disabled
        -Dgraphite2=disabled
        -Dbuildtype=release
  BUILD_COMMAND     ${STOPBUILD} ${HARFBUZZ_BYPRODUCTS} meson compile -C "${HARFBUZZ_BUILD_DIR}"
  INSTALL_COMMAND   ${STOPBUILD} ${HARFBUZZ_BYPRODUCTS} meson install -C "${HARFBUZZ_BUILD_DIR}"
)
#endregion

add_dependencies(harfbuzz freetype fribidi)

#region libass
set(LIBASS_SOURCE_DIR "${CMAKE_BINARY_DIR}/libass")
set(LIBASS_BUILD_DIR  "${CMAKE_BINARY_DIR}/libass-build")
set(LIBASS_BYPRODUCTS ${MPV_LIB}/libass.so)

ExternalProject_Add(libass
  GIT_REPOSITORY  https://github.com/libass/libass.git
  GIT_TAG         0.15.2
  GIT_SHALLOW     1

  SOURCE_DIR        "${LIBASS_SOURCE_DIR}"
  BINARY_DIR        "${LIBASS_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBASS_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${LIBASS_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${LIBASS_BYPRODUCTS}
      ./autogen.sh &&
    cd "${LIBASS_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBASS_BYPRODUCTS}
      "${LIBASS_SOURCE_DIR}/configure"
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-require-system-font-provider
        --disable-fontconfig
        CFLAGS=-fPIC
        CXXFLAGS=-fPIC

  BUILD_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBASS_BYPRODUCTS}
      make -C "${LIBASS_BUILD_DIR}" -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${LIBASS_BYPRODUCTS} make -C "${LIBASS_BUILD_DIR}" install
)
#endregion

add_dependencies(libass freetype harfbuzz)

#region libplacebo
set(LIBPLACEBO_SOURCE_DIR "${CMAKE_BINARY_DIR}/libplacebo")
set(LIBPLACEBO_BUILD_DIR  "${CMAKE_BINARY_DIR}/libplacebo-build")
set(LIBPLACEBO_BYPRODUCTS ${MPV_LIB}/libplacebo.so)

ExternalProject_Add(libplacebo
  GIT_REPOSITORY  https://github.com/haasn/libplacebo.git
  GIT_TAG         v4.192.1
  GIT_SHALLOW     1

  SOURCE_DIR        "${LIBPLACEBO_SOURCE_DIR}"
  BINARY_DIR        "${LIBPLACEBO_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBPLACEBO_BYPRODUCTS}"

  CONFIGURE_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBPLACEBO_BYPRODUCTS}
      meson setup
        "${LIBPLACEBO_BUILD_DIR}"
        "${LIBPLACEBO_SOURCE_DIR}"
        --warnlevel=0
        --prefix=${MPV_PREFIX}
        -Dc_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dcpp_link_args=-Wl,-rpath-link=${MPV_LIB}
        --libdir=lib
        -Dvulkan=disabled
        -Ddemos=false

  BUILD_COMMAND     ${STOPBUILD} ${LIBPLACEBO_BYPRODUCTS} meson compile -C ${LIBPLACEBO_BUILD_DIR}
  INSTALL_COMMAND   ${STOPBUILD} ${LIBPLACEBO_BYPRODUCTS} meson install -C ${LIBPLACEBO_BUILD_DIR}
)
#endregion

#region alsa
set(ALSA_SOURCE_DIR "${CMAKE_BINARY_DIR}/alsa")
set(ALSA_BUILD_DIR  "${CMAKE_BINARY_DIR}/alsa-build")
set(ALSA_BYPRODUCTS ${MPV_LIB}/libasound.so)

ExternalProject_Add(alsa
  GIT_REPOSITORY  https://github.com/alsa-project/alsa-lib.git
  GIT_TAG         v1.2.15.1
  GIT_SHALLOW     1

  SOURCE_DIR        "${ALSA_SOURCE_DIR}"
  BINARY_DIR        "${ALSA_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${MPV_LIB}/libasound.so"

  CONFIGURE_COMMAND
    cd "${ALSA_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      libtoolize --force --copy --automake &&
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      aclocal &&
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      autoheader &&
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      automake --foreign --copy --add-missing &&
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      autoconf &&
    cd "${ALSA_BUILD_DIR}" &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${ALSA_BYPRODUCTS}
      ${ALSA_SOURCE_DIR}/configure 
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-aload

  BUILD_COMMAND     ${STOPBUILD} ${ALSA_BYPRODUCTS} make -C ${ALSA_BUILD_DIR} -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${ALSA_BYPRODUCTS} make -C ${ALSA_BUILD_DIR} install
)
#endregion

#region libsndfile
set(LIBSNDFILE_SOURCE_DIR "${CMAKE_BINARY_DIR}/libsndfile")
set(LIBSNDFILE_BUILD_DIR "${CMAKE_BINARY_DIR}/libsndfile-build")
set(LIBSNDFILE_BYPRODUCTS ${MPV_LIB}/libsndfile.so)

ExternalProject_Add(libsndfile
  URL https://github.com/libsndfile/libsndfile/releases/download/1.2.2/libsndfile-1.2.2.tar.xz
  URL_HASH SHA256=3799ca9924d3125038880367bf1468e53a1b7e3686a934f098b7e1d286cdb80e

  SOURCE_DIR        "${LIBSNDFILE_SOURCE_DIR}"
  BINARY_DIR        "${LIBSNDFILE_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBSNDFILE_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd ${LIBSNDFILE_SOURCE_DIR} &&
    ${STOPBUILD}
      ${LIBSNDFILE_BYPRODUCTS}
      autoreconf -vif &&
    cd ${LIBSNDFILE_BUILD_DIR} &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBSNDFILE_BYPRODUCTS}
      ${LIBSNDFILE_SOURCE_DIR}/configure
        --prefix=${MPV_PREFIX}
        --disable-static
        --enable-shared
        --disable-aload

  BUILD_COMMAND     ${STOPBUILD} ${LIBSNDFILE_BYPRODUCTS} make -C ${LIBSNDFILE_BUILD_DIR} -j${NPROC}
  INSTALL_COMMAND   ${STOPBUILD} ${LIBSNDFILE_BYPRODUCTS} make -C ${LIBSNDFILE_BUILD_DIR} install
)
#endregion

#region pulseaudio
set(PULSEAUDIO_SOURCE_DIR "${CMAKE_BINARY_DIR}/pulseaudio")
set(PULSEAUDIO_BUILD_DIR  "${CMAKE_BINARY_DIR}/pulseaudio-build")
set(PULSEAUDIO_BYPRODUCTS ${MPV_LIB}/libpulse.so)

ExternalProject_Add(pulseaudio
  URL https://www.freedesktop.org/software/pulseaudio/releases/pulseaudio-17.0.tar.xz
  URL_HASH SHA256=053794d6671a3e397d849e478a80b82a63cb9d8ca296bd35b73317bb5ceb87b5

  SOURCE_DIR        "${PULSEAUDIO_SOURCE_DIR}"
  BINARY_DIR        "${PULSEAUDIO_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${PULSEAUDIO_BYPRODUCTS}"

  CONFIGURE_COMMAND
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${PULSEAUDIO_BYPRODUCTS}
      meson setup
        "${PULSEAUDIO_BUILD_DIR}"
        "${PULSEAUDIO_SOURCE_DIR}"
        --warnlevel=0
        --prefix=${MPV_PREFIX}
        -Dc_link_args=-Wl,-rpath-link=${MPV_LIB}
        -Dcpp_link_args=-Wl,-rpath-link=${MPV_LIB}
        --libdir=lib
        -Ddaemon=false
        -Dtests=false
        -Dman=false
        -Ddoxygen=false
        -Dsystemd=disabled
        -Ddbus=disabled
        -Dbluez5=disabled
        -Dudev=disabled
        -Dopenssl=disabled
        -Dgsettings=disabled
        -Dgtk=disabled

  BUILD_COMMAND     ${STOPBUILD} ${PULSEAUDIO_BYPRODUCTS} ninja -C ${PULSEAUDIO_BUILD_DIR}
  INSTALL_COMMAND   ${STOPBUILD} ${PULSEAUDIO_BYPRODUCTS} ninja -C ${PULSEAUDIO_BUILD_DIR} install
)
#endregion

add_dependencies(pulseaudio libsndfile)

#region libmpv
set(LIBMPV_SOURCE_DIR "${CMAKE_BINARY_DIR}/mpv")
set(LIBMPV_BUILD_DIR  "${CMAKE_BINARY_DIR}/libmpv-build")
set(LIBMPV_BYPRODUCTS ${MPV_LIB}/libmpv.so)

ExternalProject_Add(libmpv
  GIT_REPOSITORY  https://github.com/mpv-player/mpv.git
  GIT_TAG         v0.34.1
  GIT_SHALLOW     1

  SOURCE_DIR        "${LIBMPV_SOURCE_DIR}"
  BINARY_DIR        "${LIBMPV_BUILD_DIR}"
  BUILD_BYPRODUCTS  "${LIBMPV_BYPRODUCTS}"

  CONFIGURE_COMMAND
    cd "${LIBMPV_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${LIBMPV_BYPRODUCTS}
      python3 bootstrap.py &&
    ${CMAKE_COMMAND} -E env ${PREFIX_ENV}
    ${STOPBUILD}
      ${LIBMPV_BYPRODUCTS}
      ${LIBMPV_SOURCE_DIR}/waf configure
        --prefix=${MPV_PREFIX}
        --libdir=lib
        --disable-vapoursynth
        --disable-manpage-build
        --disable-tests
        --disable-lua
        --disable-uchardet
        --disable-x11
        --disable-wayland
        --disable-drm
        --disable-gbm
        --disable-sdl2
        --disable-cocoa
        --disable-win32
        --disable-javascript
        --enable-libmpv-shared
        --enable-gl
        --enable-alsa
        --enable-pulse

  BUILD_COMMAND
    cd "${LIBMPV_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${LIBMPV_BYPRODUCTS}
      ${LIBMPV_SOURCE_DIR}/waf build -j${NPROC}

  INSTALL_COMMAND
    cd "${LIBMPV_SOURCE_DIR}" &&
    ${STOPBUILD}
      ${LIBMPV_BYPRODUCTS}
      ${LIBMPV_SOURCE_DIR}/waf install
)
#endregion

add_dependencies(libmpv ffmpeg libass libplacebo alsa pulseaudio)

add_library(mpv SHARED IMPORTED)
set_target_properties(mpv PROPERTIES
  IMPORTED_LOCATION "${MPV_LIB}/libmpv.so"
)

add_dependencies(mpv libmpv)
