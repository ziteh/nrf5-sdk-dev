
FROM ubuntu:22.04 AS base

FROM base AS downloader

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /downloads

# ARM GCC toolchain
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
    echo "Downloading ARM GCC for ARM64/aarch64..." && \
    wget -q -O gcc-arm-none-eabi.tar.bz2 https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-aarch64-linux.tar.bz2; \
    else \
    echo "Downloading ARM GCC for x86_64..." && \
    wget -q -O gcc-arm-none-eabi.tar.bz2 https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2; \
    fi

RUN tar -xjf gcc-arm-none-eabi.tar.bz2 \
    && mv gcc-arm-none-eabi-10.3-2021.10 arm-gcc \
    && rm gcc-arm-none-eabi.tar.bz2 \
    && rm -rf arm-gcc/share/doc

# nRF Command Line Tools
# RUN ARCH=$(uname -m) && \
#     if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
#     echo "Downloading nRF CLI for ARM64/aarch64..." && \
#     wget -q -O nrf-command-line-tools.tar.gz https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools-10.24.2_linux-arm64.tar.gz; \
#     else \
#     echo "Downloading nRF CLI for x86_64..." && \
#     wget -q -O nrf-command-line-tools.tar.gz https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools-10.24.2_linux-amd64.tar.gz; \
#     fi

FROM base AS development

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    gdb-multiarch \
    ccache \
    ninja-build \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ARM GCC toolchain
COPY --from=downloader /downloads/arm-gcc /opt/arm-gcc

ENV PATH="/opt/arm-gcc/bin:${PATH}"

# nRF Command Line Tools
# COPY --from=downloader /downloads/nrf-command-line-tools.tar.gz .
# RUN tar -xzf nrf-command-line-tools.tar.gz \
#     && find . -maxdepth 1 -type d -name "nrf-command-line-tools*" -exec mv {} nrf-cli-tools \; \
#     && rm nrf-command-line-tools.tar.gz

# ENV PATH="/opt/nrf-cli-tools/bin:${PATH}"

RUN useradd -m -s /bin/bash developer \
    && chown -R developer:developer /opt

# Setup ccache symlinks for ARM GCC
RUN mkdir -p /opt/ccache-links && \
    ln -s /usr/bin/ccache /opt/ccache-links/arm-none-eabi-gcc && \
    ln -s /usr/bin/ccache /opt/ccache-links/arm-none-eabi-g++

# Pre-create build cache directory with correct ownership
RUN mkdir -p /workspace/.build-cache/ccache && \
    chown -R developer:developer /workspace/.build-cache

USER developer
WORKDIR /workspace

ENV NRF5_SDK_PATH="/opt/nrf5-sdk"
ENV GNU_INSTALL_ROOT="/opt/arm-gcc/bin/"
# ENV GNU_VERSION="10.3-2021.10"
# ENV GNU_PREFIX="arm-none-eabi"

# Enable ccache
ENV PATH="/opt/ccache-links:${PATH}"
ENV CCACHE_DIR="/workspace/.build-cache/ccache"
ENV CCACHE_MAXSIZE="1G"
ENV CCACHE_COMPRESS="1"
