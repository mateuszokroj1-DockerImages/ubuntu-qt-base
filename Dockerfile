FROM mateuszokroj1/ubuntu-dev-base:latest

WORKDIR /home

ENV CC=clang \
    CXX=clang++ \
    VCPKG_OVERLAY_TRIPLETS=/home/vcpkg-triplets

COPY vcpkg.json .
COPY triplets/ /home/vcpkg-triplets/

RUN --mount=type=cache,target=/root/.cache/vcpkg/archives \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf autoconf-archive automake bison flex libegl1-mesa-dev libglu1-mesa-dev \
        libice-dev libltdl-dev libsm-dev libtool libx11-xcb-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libxrender-dev \
        pkg-config python3-venv '^libxcb.*-dev$' \
    && rm -rf /var/lib/apt/lists/*

RUN vcpkg install

RUN rm vcpkg.json