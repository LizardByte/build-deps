# CPM Package Lock
# This file should be committed to version control

# The first argument of CPMDeclarePackage can be freely chosen and is used as argument in CPMGetPackage.
# The NAME argument should be package name that would also be used in a find_package call.
# Ideally, both are the same, which might not always be possible: https://github.com/cpm-cmake/CPM.cmake/issues/603
# This is needed to support CPM_USE_LOCAL_PACKAGES

# Renovate-bot will update the versions and hashes in this file when a new version of a dependency is released.
# The comments above each dependency are used by renovate to identify the dependencies and extract the version numbers.
# See https://github.com/LizardByte/.github/blob/master/renovate/cmake.json5 for the configuration of renovate.
# See https://github.com/LizardByte/.github/blob/master/renovate/README.md#cpm-package-lock for annotation instructions.

set(PATCH_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/patches/FFmpeg")

# AMF
# renovate: datasource=github-tags depName=GPUOpen-LibrariesAndSDKs/AMF
# extractVersion=^v(?<version>.*)$
set(AMF_VERSION 1.5.3)
CPMDeclarePackage(amf
        NAME amf
        VERSION ${AMF_VERSION}
        # The archive avoids cloning the SDK's Git history.
        URL https://github.com/GPUOpen-LibrariesAndSDKs/AMF/archive/refs/tags/v${AMF_VERSION}.tar.gz
        TLS_VERIFY TRUE
        DOWNLOAD_ONLY YES
)

# dav1d
# renovate: datasource=github-tags depName=videolan/dav1d
set(DAV1D_VERSION 1.5.5)
CPMDeclarePackage(dav1d
        NAME dav1d
        VERSION ${DAV1D_VERSION}
        GIT_REPOSITORY https://github.com/videolan/dav1d.git
        GIT_TAG ${DAV1D_VERSION}
        DOWNLOAD_ONLY YES
)

# FFmpeg
# renovate: datasource=github-tags depName=FFmpeg/FFmpeg
# versioning=regex:^n(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?$
set(FFMPEG_TAG n9.1)
file(GLOB_RECURSE FFMPEG_PATCHES CONFIGURE_DEPENDS "${PATCH_DIRECTORY}/FFmpeg/*.patch")
CPMDeclarePackage(ffmpeg
        NAME ffmpeg
        GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
        GIT_TAG ${FFMPEG_TAG}
        GIT_SHALLOW TRUE
        GIT_CONFIG core.autocrlf=false
        SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/ffmpeg-${FFMPEG_TAG}"  # Clean checkout when the tag changes.
        UPDATE_DISCONNECTED TRUE  # Keep patches from running again on reconfigure.
        DOWNLOAD_ONLY YES
        PATCHES ${FFMPEG_PATCHES}
)

CPMDeclarePackage(ffmpeg_nxdk
        NAME ffmpeg_nxdk
        GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
        GIT_TAG ${FFMPEG_TAG}
        GIT_SHALLOW TRUE
        GIT_CONFIG core.autocrlf=false
        SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/ffmpeg-nxdk-${FFMPEG_TAG}"
        UPDATE_DISCONNECTED TRUE
        DOWNLOAD_ONLY YES
        PATCHES "${PATCH_DIRECTORY}/nxdk/ffmpeg-nxdk.patch"
)

# nxdk
# renovate: datasource=git-refs depName=XboxDev/nxdk
# ref=master
set(NXDK_COMMIT fafbe41b48fa00a31b79dd49ad1f86a30adcdd9e)
CPMDeclarePackage(nxdk
        NAME nxdk
        GIT_REPOSITORY https://github.com/XboxDev/nxdk.git
        GIT_TAG ${NXDK_COMMIT}
        GIT_CONFIG core.autocrlf=false
        GIT_SUBMODULES lib/libcxx lib/net/lwip lib/pdclib
        GIT_SUBMODULES_RECURSE FALSE
        NO_CACHE YES
        DOWNLOAD_ONLY YES
)

# libva
# renovate: datasource=github-tags depName=intel/libva
set(LIBVA_VERSION 2.24.1)
CPMDeclarePackage(libva
        NAME libva
        VERSION ${LIBVA_VERSION}
        GIT_REPOSITORY https://github.com/intel/libva.git
        GIT_TAG ${LIBVA_VERSION}
        NO_CACHE YES  # libva's autotools build writes into the checkout
        DOWNLOAD_ONLY YES
)

# nv-codec-headers 11.0
# renovate: datasource=github-tags depName=FFmpeg/nv-codec-headers
# versioning=regex:^n(?<major>11)\.(?<minor>0)\.(?<patch>\d+)\.(?<build>\d+)$
set(NV_CODEC_HEADERS_11_TAG n11.0.10.3)
CPMDeclarePackage(nv_codec_headers_11
        NAME nv_codec_headers_11
        GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers.git
        GIT_TAG ${NV_CODEC_HEADERS_11_TAG}
        DOWNLOAD_ONLY YES
)

# nv-codec-headers 12.0
# renovate: datasource=github-tags depName=FFmpeg/nv-codec-headers
# versioning=regex:^n(?<major>12)\.(?<minor>0)\.(?<patch>\d+)\.(?<build>\d+)$
set(NV_CODEC_HEADERS_12_TAG n12.0.16.2)
CPMDeclarePackage(nv_codec_headers_12
        NAME nv_codec_headers_12
        GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers.git
        GIT_TAG ${NV_CODEC_HEADERS_12_TAG}
        DOWNLOAD_ONLY YES
)

# nv-codec-headers 13.0
# renovate: datasource=github-tags depName=FFmpeg/nv-codec-headers
# versioning=regex:^n(?<major>13)\.(?<minor>0)\.(?<patch>\d+)\.(?<build>\d+)$
set(NV_CODEC_HEADERS_13_TAG n13.0.19.1)
CPMDeclarePackage(nv_codec_headers_13
        NAME nv_codec_headers_13
        GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers.git
        GIT_TAG ${NV_CODEC_HEADERS_13_TAG}
        DOWNLOAD_ONLY YES
)

# nv-codec-headers 13.1
# renovate: datasource=github-tags depName=FFmpeg/nv-codec-headers
# versioning=regex:^n(?<major>13)\.(?<minor>1)\.(?<patch>\d+)\.(?<build>\d+)$
set(NV_CODEC_HEADERS_13_1_TAG n13.1.15.0)
CPMDeclarePackage(nv_codec_headers_13_1
        NAME nv_codec_headers_13_1
        GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers.git
        GIT_TAG ${NV_CODEC_HEADERS_13_1_TAG}
        DOWNLOAD_ONLY YES
)

# Opus
# renovate: datasource=github-tags depName=xiph/opus
# extractVersion=^v(?<version>.*)$
set(OPUS_VERSION 1.6.1)
CPMDeclarePackage(opus
        NAME opus
        VERSION ${OPUS_VERSION}
        GIT_REPOSITORY https://github.com/xiph/opus.git
        GIT_TAG v${OPUS_VERSION}
        GIT_SHALLOW TRUE
        GIT_CONFIG core.autocrlf=false
        SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/opus-${OPUS_VERSION}"
        UPDATE_DISCONNECTED TRUE
        DOWNLOAD_ONLY YES
        PATCHES "${PATCH_DIRECTORY}/opus/cmake-presumed-neon.patch"
)

# SVT-AV1
# renovate: datasource=github-tags depName=AOMediaCodec/SVT-AV1
set(SVT_AV1_TAG v4.3.0)
CPMDeclarePackage(svt_av1
        NAME svt_av1
        GIT_REPOSITORY https://github.com/LizardByte-infrastructure/SVT-AV1.git
        GIT_TAG ${SVT_AV1_TAG}
        GIT_SHALLOW TRUE
        DOWNLOAD_ONLY YES
)

# Vulkan Loader
# renovate: datasource=github-tags depName=KhronosGroup/Vulkan-Loader
set(VULKAN_TAG v1.4.369)
CPMDeclarePackage(vulkan_loader
        NAME vulkan_loader
        GIT_REPOSITORY https://github.com/KhronosGroup/Vulkan-Loader.git
        GIT_TAG ${VULKAN_TAG}
        GIT_SHALLOW TRUE
        DOWNLOAD_ONLY YES
)

# Vulkan Headers
CPMDeclarePackage(vulkan_headers
        NAME vulkan_headers
        GIT_REPOSITORY https://github.com/KhronosGroup/Vulkan-Headers.git
        GIT_TAG ${VULKAN_TAG}  # Match the Loader release.
        GIT_SHALLOW TRUE
        DOWNLOAD_ONLY YES
)

# x264
# renovate: datasource=git-refs depName=videolan/x264
# ref=stable
set(X264_COMMIT b35605ace3ddf7c1a5d67a2eb553f034aef41d55)
CPMDeclarePackage(x264
        NAME x264
        GIT_REPOSITORY https://github.com/LizardByte-infrastructure/x264.git
        GIT_TAG ${X264_COMMIT}
        GIT_CONFIG core.autocrlf=false
        NO_CACHE YES  # x264 builds in the checkout
        DOWNLOAD_ONLY YES
)

# x265
# renovate: datasource=github-tags depName=Multicorewareinc/x265
set(X265_TAG 4.2)
file(GLOB X265_PATCHES CONFIGURE_DEPENDS "${PATCH_DIRECTORY}/x265_git/*.patch")
CPMDeclarePackage(x265
        NAME x265
        GIT_REPOSITORY https://github.com/LizardByte-infrastructure/x265_git.git
        GIT_TAG ${X265_TAG}  # x265 uses the Git tag to generate x265.pc.
        GIT_SHALLOW TRUE
        GIT_CONFIG core.autocrlf=false
        SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps/x265-${X265_TAG}"
        UPDATE_DISCONNECTED TRUE
        DOWNLOAD_ONLY YES
        PATCHES ${X265_PATCHES}
)
