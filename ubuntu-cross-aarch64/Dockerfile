# Keep the published tag ubuntu-cross-aarch64 when advancing the Ubuntu base.
ARG UBUNTU_RELEASE=resolute
FROM docker.io/library/ubuntu:${UBUNTU_RELEASE}

LABEL maintainer="Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}

# amd64 build tools, arm64 libraries. The completed image provides explicit
# QEMU wrappers for helpers, so Workrave builds need no host binfmt setup.
RUN \
  test "$(dpkg --print-architecture)" = amd64 && \
  dpkg --add-architecture arm64 && \
  sed -i '/^Types: deb/a Architectures: amd64' /etc/apt/sources.list.d/ubuntu.sources && \
  . /etc/os-release && \
  printf 'Types: deb\nURIs: http://ports.ubuntu.com/ubuntu-ports\nSuites: %s %s-updates %s-security\nComponents: main restricted universe multiverse\nArchitectures: arm64\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n' \
    "$VERSION_CODENAME" "$VERSION_CODENAME" "$VERSION_CODENAME" \
    > /etc/apt/sources.list.d/arm64.sources && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    appstream \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    curl \
    file \
    g++-aarch64-linux-gnu \
    gettext \
    git \
    gobject-introspection \
    gsettings-desktop-schemas \
    intltool \
    jq \
    libclang-dev \
    libglib2.0-bin \
    libglib2.0-dev-bin \
    ninja-build \
    patchelf \
    pkg-config \
    python3 \
    python3-setuptools \
    qemu-user \
    squashfs-tools \
    xz-utils \
    libayatana-appindicator-glib-dev:arm64 \
    libayatana-appindicator3-dev:arm64 \
    libayatana-indicator3-dev:arm64 \
    libboost-date-time-dev:arm64 \
    libboost-program-options-dev:arm64 \
    libboost-serialization-dev:arm64 \
    libdbusmenu-glib-dev:arm64 \
    libdbusmenu-gtk3-dev:arm64 \
    libgirepository1.0-dev:arm64 \
    libgnome-panel-dev:arm64 \
    libgstreamer1.0-dev:arm64 \
    libgtk-3-dev:arm64 \
    libgtkmm-3.0-dev:arm64 \
    libmate-panel-applet-dev:arm64 \
    libpulse-dev:arm64 \
    librsvg2-dev:arm64 \
    libspdlog-dev:arm64 \
    libsqlite3-dev:arm64 \
    libwayland-dev:arm64 \
    libxfce4panel-2.0-dev:arm64 \
    libxfce4ui-2-dev:arm64 \
    libxi-dev:arm64 \
    libxmu-dev:arm64 \
    libxss-dev:arm64 \
    libxtst-dev:arm64 \
    wayland-protocols \
    libwayland-bin && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /workrave && \
  printf '%s\n' "$GIT_COMMIT_HASH" > /workrave/container-commit

# clang-rpc-gen is a build-host executable, not part of the ARM64 payload.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable

COPY aarch64-linux-gnu.cmake /opt/workrave/aarch64-linux-gnu.cmake
COPY bin/ /opt/workrave/bin/
RUN chmod +x /opt/workrave/bin/* && \
  ln -s run-aarch64 /opt/workrave/bin/aarch64-linux-gnu-cross-exe-wrapper && \
  ln -s target-tool /opt/workrave/bin/gtk-query-immodules-3.0 && \
  ln -s target-tool /opt/workrave/bin/gdk-pixbuf-query-loaders

ENV PATH="/opt/workrave/bin:/root/.cargo/bin:${PATH}" \
    CONF_TOOLCHAIN_FILE=/opt/workrave/aarch64-linux-gnu.cmake \
    CONF_TARGET_ARCH=aarch64 \
    PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig \
    PKG_CONFIG_PATH="" \
    LD_GTK_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu \
    APPIMAGE_EXTRACT_AND_RUN=1

CMD ["/bin/bash"]
