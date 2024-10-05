# build-deps

[![GitHub Workflow Status (FFmpeg)](https://img.shields.io/github/actions/workflow/status/lizardbyte/build-deps/build-ffmpeg.yml.svg?branch=master&label=ffmpeg%20build&logo=github&style=for-the-badge)](https://github.com/LizardByte/build-deps/actions/workflows/build-ffmpeg.yml?query=branch%3Amaster)

This is a common set of pre-compiled dependencies for LizardByte/Sunshine.

- [FFmpeg](https://ffmpeg.org)

## Usage

1. Add this repository as a submodule to your project.

   ```bash
   git submodule add https://github.com/LizardByte/build-deps.git third-party/build-deps
   cd third-party/build-deps
   git submodule update --init --recursive
   checkout dist
   ```

## Plans

- [ ] Convert to a cmake project
- [ ] Add more dependencies
  - [ ] boost
  - [ ] cuda (developer toolkit)
- [ ] build linux dependencies in Docker (to more closely align with target environments)

## License

This repo is licensed under the MIT License, but this does not cover submodules or patches.
Please see the individual projects for their respective licenses.
