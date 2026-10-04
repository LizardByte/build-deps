<div align="center">
  <img
    src="https://raw.githubusercontent.com/LizardByte/.github/refs/heads/master/branding/logos/logo.svg"
    alt="LizardByte icon"
    width="256"
  />
  <h1 align="center">LizardByte build deps</h1>
  <h4 align="center">Prebuilt dependencies for LizardByte projects.</h4>
</div>

<div align="center">
  <a href="https://github.com/LizardByte/build-deps/actions/workflows/ci.yml?query=branch%3Amaster"><img src="https://img.shields.io/github/actions/workflow/status/lizardbyte/build-deps/ci.yml.svg?branch=master&label=build&logo=github&style=for-the-badge" alt="GitHub Workflow Status (CI)"></a>
  <a href="https://sonarcloud.io/project/overview?id=LizardByte_build-deps"><img src="https://img.shields.io/sonar/quality_gate/LizardByte_build-deps.svg?server=https%3A%2F%2Fsonarcloud.io&style=for-the-badge&logo=sonarqubecloud&label=sonarcloud" alt="SonarCloud"></a>
</div>

## Overview

This is a common set of pre-compiled dependencies for [Sunshine](https://github.com/LizardByte/Sunshine),
[Koko](https://github.com/LizardByte/Koko), [One](https://github.com/LizardByte/One), and other LizardByte projects.

- [FFmpeg](https://ffmpeg.org): static libraries with encoders, decoders, formats, filters, and protocols;
  `ffmpeg` and `ffprobe` executables; and Sunshine's `libcbs` helpers.
- [dav1d](https://code.videolan.org/videolan/dav1d): AV1 decoder.
- [Opus](https://opus-codec.org): audio codec, usable directly by consumers as well as through FFmpeg.

## Usage

Download the matching `<platform>-ffmpeg.tar.gz` archive from a
[release](https://github.com/LizardByte/build-deps/releases), and extract its `ffmpeg` directory.
The package contains `include`, `lib`, `lib/pkgconfig`, `bin`, and `share/licenses`. CI builds encoders,
decoders, and tools together for each platform. Pin the release tag and archive SHA256 in reproducible builds.

For applications linking the static libraries, point `PKG_CONFIG_PATH` at the extracted `lib/pkgconfig`
directory and use `pkg-config --static` to obtain the complete link dependencies. The pkg-config files are
relocatable. Platform graphics and system development libraries may still be required when linking hardware
acceleration support. Windows archives use the MSYS2 MinGW toolchain and include the static oneVPL dispatcher.

To build the dependencies from source:

1. Add this repository as a submodule to your project.

   ```bash
   git submodule add https://github.com/LizardByte/build-deps.git third-party/build-deps
   cd third-party/build-deps
   git submodule update --init --recursive
   ```

## License

This repo is licensed under the MIT License, but this does not cover submodules or patches.
Please see the individual projects for their respective licenses.


## Build

### Checkout

```bash
git clone --recurse-submodules https://github.com/LizardByte/build-deps.git
```

You can reduce the size of the repo by setting the depth to 1:

```bash
git clone --recurse-submodules --depth 1 https://github.com/LizardByte/build-deps.git
```

ℹ️ If you have already cloned the repository without submodules, you can initialize them with the following command:

```bash
cd build-deps
git submodule update --init --recursive
```

### Line Endings

ℹ️ On Windows, you must copy the `.gitattributes` file to `.git/modules/third-party/FFmpeg/x264/info/attributes`,
see https://stackoverflow.com/a/23671157/11214013 for more info.

Then run the following commands:
```bash
cd third-party/FFmpeg/x264
git checkout HEAD -- .
```

### Dependencies

#### FreeBSD

```bash
pkg install -y \
  devel/autoconf \
  devel/automake \
  devel/cmake \
  devel/git \
  devel/gmake \
  devel/meson \
  devel/nasm \
  devel/ninja \
  devel/pkgconf \
  multimedia/libass \
  multimedia/libv4l \
  multimedia/libva \
  multimedia/v4l_compat \
  print/freetype2 \
  security/gnutls \
  shells/bash \
  x11/libxcb \
  x11/libX11 \
  x11/libXfixes
```

#### Linux

##### Debian/Ubuntu

```bash
sudo apt install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    git-core \
    libass-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libnuma-dev \
    libopus-dev \
    libsdl2-dev \
    libtool \
    meson \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    make \
    meson \
    nasm \
    ninja-build \
    pkg-config \
    texinfo \
    wget \
    zlib1g-dev
```

#### Alpine

```bash
apk add --no-cache \
    autoconf \
    automake \
    bash \
    build-base \
    cmake \
    git \
    libdrm-dev \
    libtool \
    libx11-dev \
    libxcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxrandr-dev \
    linux-headers \
    mesa-dev \
    meson \
    nasm \
    ninja \
    numactl-dev \
    pkgconf \
    wayland-dev
```

#### macOS

```bash
brew install \
    automake \
    git \
    lame \
    libass \
    libtool \
    libvorbis \
    libvpx \
    meson \
    nasm \
    ninja \
    opus \
    pkg-config \
    sdl \
    shtool \
    texi2html \
    theora \
    wget \
    xvid
```

#### Windows

ℹ️ Cross-compilation is not supported on Windows. You must build on the target architecture.

First, install [MSYS2](https://www.msys2.org/).

##### x86_64 / amd64

Open the UCRT64 shell and run the following commands:

```bash
pacman -Syu
pacman -S \
    diffutils \
    git \
    make \
    patch \
    pkg-config \
    mingw-w64-ucrt-x86_64-binutils \
    mingw-w64-ucrt-x86_64-cmake \
    mingw-w64-ucrt-x86_64-gcc \
    mingw-w64-ucrt-x86_64-make \
    mingw-w64-ucrt-x86_64-meson \
    mingw-w64-ucrt-x86_64-nasm \
    mingw-w64-ucrt-x86_64-ninja \
    mingw-w64-ucrt-x86_64-onevpl
```

##### aarch64 / arm64

Open the CLANGARM64 shell and run the following commands:

```bash
pacman -Syu
pacman -S \
    diffutils \
    git \
    make \
    patch \
    pkg-config \
    mingw-w64-clang-aarch64-binutils \
    mingw-w64-clang-aarch64-cmake \
    mingw-w64-clang-aarch64-gcc \
    mingw-w64-clang-aarch64-make \
    mingw-w64-clang-aarch64-meson \
    mingw-w64-clang-aarch64-nasm \
    mingw-w64-clang-aarch64-ninja \
    mingw-w64-clang-aarch64-onevpl
```

### Configure

Encoders, decoders, and tools are built together by default. Set `BUILD_FFMPEG_ENCODERS`,
`BUILD_FFMPEG_DECODERS`, or `BUILD_FFMPEG_TOOLS` to `OFF` for a smaller custom build.
FFmpeg's built-in software decoders use `BUILD_FFMPEG_DECODERS`; they do not need x264, x265, or SVT-AV1.
The dependency switches have the following roles, subject to platform support:

| Switch                                                           | Encoding                  | Decoding            |
|------------------------------------------------------------------|---------------------------|---------------------|
| `BUILD_FFMPEG_X264`, `BUILD_FFMPEG_X265`, `BUILD_FFMPEG_SVT_AV1` | Software encoders         | No                  |
| `BUILD_FFMPEG_MF`                                                | Media Foundation encoders | No                  |
| `BUILD_FFMPEG_AMF`                                               | AMD AMF encoders          | AMD AMF decoders    |
| `BUILD_FFMPEG_NV_CODEC_HEADERS`                                  | NVIDIA NVENC              | NVIDIA NVDEC/CUVID  |
| `BUILD_FFMPEG_LIBVA`                                             | VA-API encoders           | VA-API acceleration |
| `BUILD_FFMPEG_VULKAN`                                            | Vulkan encoders           | Vulkan acceleration |
| `BUILD_FFMPEG_V4L2`                                              | V4L2 M2M encoders         | V4L2 M2M decoders   |
| `BUILD_FFMPEG_DAV1D`                                             | No                        | AV1 decoder         |
| `BUILD_FFMPEG_OPUS`                                              | Opus encoder              | Opus decoder        |

Disabling encoders preserves shared hardware backends for decoding. Windows D3D11VA, D3D12VA, DXVA2,
and oneVPL/QSV, and macOS VideoToolbox are enabled by the platform configuration rather than separate
dependency switches.

Use the `Unix Makefiles` generator for Linux and macOS, and the `MSYS Makefiles` generator for Windows.

#### Standard

```bash
mkdir -p ./build/dist
cmake \
    -B ./build \
    -S . \
    -G "<generator>" \
    -DCMAKE_INSTALL_PREFIX=./build/dist
```

#### Cross Compile

```bash
mkdir -p ./build/dist
cmake \
    -B ./build \
    -S . \
    -G "<generator>" \
    -DCMAKE_INSTALL_PREFIX=./build/dist \
    -DCMAKE_TOOLCHAIN_FILE=./cmake/toolchains/<target>.cmake
```

#### Windows

ℹ️ On Windows, the environment is sometimes not properly passed to the `make` subprocesses. To account for this, there
are three options. If the default does not work, you can try passing in the following flags:

```bash
-DMSYS2_OPTION=3
```

Valid options are, 1, 2, and 3. The default is 1.

### Build

ℹ️ On FreeBSD, use `gmake` instead of `make`.

```bash
make -C build
```

### Install

⚠️ It is critical that the `-DCMAKE_INSTALL_PREFIX` is set to the path where you want to install the dependencies.

```bash
make -C build install
```
