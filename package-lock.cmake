# CPM Package Lock
# This file should be committed to version control

# The first argument of CPMDeclarePackage can be freely chosen and is used as argument in CPMGetPackage.
# The NAME argument should be package name that would also be used in a find_package call.
# Ideally, both are the same, which might not always be possible: https://github.com/cpm-cmake/CPM.cmake/issues/603
# This is needed to support CPM_USE_LOCAL_PACKAGES

# Renovate-bot will update the versions and hashes in this file when a new version of a dependency is released.
# The comments above each dependency are used by renovate to identify the dependencies and extract the version numbers.
# See https://github.com/LizardByte/.github/blob/master/renovate-config.json5 for the configuration of renovate.

set(PATCH_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/patches")

# Boost
# renovate: datasource=github-release-attachments depName=boostorg/boost extractVersion=^boost-(?<version>.+)$
set(BOOST_TAG boost-1.89.0)
set(BOOST_SHA256 67acec02d0d118b5de9eb441f5fb707b3a1cdd884be00ca24b9a73c995511f74)
string(REGEX REPLACE "^boost-" "" BOOST_VERSION "${BOOST_TAG}")
CPMDeclarePackage(Boost
        NAME Boost
        VERSION ${BOOST_VERSION}
        URL https://github.com/boostorg/boost/releases/download/${BOOST_TAG}/${BOOST_TAG}-cmake.tar.xz
        URL_HASH SHA256=${BOOST_SHA256}
        DOWNLOAD_ONLY YES
)

# libva
# renovate: datasource=github-tags depName=intel/libva
set(LIBVA_VERSION 2.23.0)
CPMDeclarePackage(libva
        NAME libva
        VERSION ${LIBVA_VERSION}
        GIT_REPOSITORY https://github.com/intel/libva.git
        GIT_TAG ${LIBVA_VERSION}
        DOWNLOAD_ONLY YES
)
