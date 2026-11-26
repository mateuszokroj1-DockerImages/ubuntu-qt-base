# Ubuntu Qt Base Image

Qt development image based on the Ubuntu development base image. It uses
vcpkg to install Qt 6 modules with the project-specific Linux x64 and ARM64
triplets.

## Operating system and architecture

- **Base image:** `mateuszokroj1/ubuntu-dev-base:ubuntu-26.04`.
- **Architecture:** `linux/amd64` (x86-64) and `linux/arm64` (ARM 64).
- **Working directory:** `/home`.
- **C and C++ compilers:** Clang and Clang++ (`CC=clang`, `CXX=clang++`).
- **Package manager:** vcpkg, with `/home/vcpkg-triplets` as the overlay
  triplet directory.

Docker selects the native architecture if `--platform` is omitted. Use
`--platform` explicitly when cross-building or when the host supports multiple
architectures.

## Build

Build the image for the native architecture:

```sh
docker build -t mateuszokroj1/ubuntu-qt-base:latest .
```

Build for amd64 explicitly:

```sh
docker build --platform linux/amd64 -t mateuszokroj1/ubuntu-qt-base:latest .
```

Build for arm64 explicitly:

```sh
docker build --platform linux/arm64 -t mateuszokroj1/ubuntu-qt-base:latest .
```

To build a single image containing both amd64 and arm64 manifests, use Docker
Buildx:

```sh
docker buildx build --platform linux/amd64,linux/arm64 \
  -t mateuszokroj1/ubuntu-qt-base:latest --push .
```

## CI/CD

Pushes to `main` or `releases/*`, and manual deployment runs, build the
`linux/amd64` and `linux/arm64` images in parallel on native GitHub-hosted
runners. After both builds succeed, the workflow publishes a single
multi-architecture manifest as
`mateuszokroj1/ubuntu-qt-base:latest`. Configure the `DOCKER_LOGIN` and
`DOCKER_DEPLOYMENT_KEY` GitHub Actions secrets to enable publishing.

## Qt and vcpkg packages

The `vcpkg.json` manifest contains the pinned Qt package baseline and versions:

| Package | Version |
|---|---|
| Qt base with widgets | `6.11.3`, port version `1` |
| Qt SVG | `6.11.3` |
| Qt Declarative (QML) | `6.11.3` |

The vcpkg baseline is pinned to
`4702e381dbbd9b54d3f7e1eb565cd8981c1814cd`. Package files can be cached by
Docker, but the cached archive directory is not copied as a runtime
configuration file.

The overlay triplets provide release, dynamic-link builds for Linux:

| Architecture | Triplet |
|---|---|
| amd64 / x64 | `triplets/x64-linux.cmake` |
| arm64 | `triplets/arm64-linux.cmake` |

Both triplets set the C and C++ PIC flags and link with `libc++`.

## Additional build dependencies

The image installs development packages required by Qt and vcpkg, including:

- Autoconf, Automake, Bison, Flex, Libtool
- EGL, GLU, X11, XRender, XKB, XCB, ICE, SM, and XI development headers
- `pkg-config`
- Python virtual environment support

APT package versions are not pinned and may change between builds.

## Usage

Start an interactive shell:

```sh
docker run --rm -it -v "$PWD:/work" -w /work \
  mateuszokroj1/ubuntu-qt-base:latest bash
```

Inside the container, the Qt packages can be found through the vcpkg
installation inherited from the Ubuntu development base image. Configure a
CMake project with the vcpkg toolchain file, for example:

```sh
cmake -S . -B build \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET=x64-linux
```

On arm64, use `-DVCPKG_TARGET_TRIPLET=arm64-linux`.

To inspect the installed environment:

```sh
cat /etc/os-release
dpkg --print-architecture
clang --version
cmake --version
vcpkg version
```
