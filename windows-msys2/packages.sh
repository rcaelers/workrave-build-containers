#!/bin/bash
set -euo pipefail

# Use the official repository directly; regional mirrors can throttle the
# many parallel package/signature requests of an SDK bootstrap.
printf 'Server = https://repo.msys2.org/mingw/$repo\n' > /etc/pacman.d/mirrorlist.mingw
printf 'Server = https://repo.msys2.org/msys/$arch\n' > /etc/pacman.d/mirrorlist.msys
sed -i 's/^ParallelDownloads.*/ParallelDownloads = 1/' /etc/pacman.conf

install_packages() {
pacman --noconfirm --needed -S \
    git curl tar xz zip \
    mingw-w64-clang-x86_64-adwaita-icon-theme \
    mingw-w64-clang-x86_64-boost \
    mingw-w64-clang-x86_64-clang \
    mingw-w64-clang-x86_64-cmake \
    mingw-w64-clang-x86_64-cmark \
    mingw-w64-clang-x86_64-gcc-compat \
    mingw-w64-clang-x86_64-gettext-tools \
    mingw-w64-clang-x86_64-gtkmm3 \
    mingw-w64-clang-x86_64-gtest \
    mingw-w64-clang-x86_64-jq \
    mingw-w64-clang-x86_64-libxml2 \
    mingw-w64-clang-x86_64-lld \
    mingw-w64-clang-x86_64-ninja \
    mingw-w64-clang-x86_64-openssl \
    mingw-w64-clang-x86_64-python \
    mingw-w64-clang-x86_64-qt6-base \
    mingw-w64-clang-x86_64-qt6-declarative \
    mingw-w64-clang-x86_64-qt6-svg \
    mingw-w64-clang-x86_64-qt6-tools \
    mingw-w64-clang-x86_64-rust \
    mingw-w64-clang-x86_64-spdlog \
    mingw-w64-clang-x86_64-sqlite3 \
    mingw-w64-clang-x86_64-uasm \
    mingw-w64-i686-gcc \
    mingw-w64-i686-cmake \
    mingw-w64-i686-ninja
}

# Retain downloaded packages between retries if a repository returns a
# transient HTTP error; never weaken package signature verification.
installed=false
for attempt in 1 2 3; do
    if install_packages; then
        installed=true
        break
    fi
done
test "$installed" = true

# Keep a record of the resolved SDK, including package versions.
pacman -Q > /c/image/packages.txt
pacman --noconfirm -Scc
