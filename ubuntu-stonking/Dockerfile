FROM ubuntu:stonking

LABEL maintainer="Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
  echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export _PYTHON_SUBPROCESS_USE_POSIX_SPAWN=0 && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get dist-upgrade -y && \
  apt-get install -y \
    python3 \
    python3-jinja2 \
    python3-paramiko \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3-inflect \
    build-essential \
    git && \
  apt-get install -y \
    nodejs \
    npm && \
  apt-get install -y \
    appstream \
    autoconf \
    autoconf-archive \
    automake \
    autopoint \
    build-essential \
    cmake \
    curl \
    debhelper \
    devscripts \
    dh-autoreconf \
    extra-cmake-modules \
    fuse \
    gettext \
    gh \
    git \
    gobject-introspection \
    gsettings-desktop-schemas-dev \
    intltool \
    jq \
    libayatana-appindicator3-dev \
    libayatana-indicator3-dev \
    libboost-chrono-dev \
    libboost-context-dev \
    libboost-coroutine-dev \
    libboost-date-time-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-log-dev \
    libboost-program-options-dev \
    libboost-regex-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libclang-dev \
    libdbusmenu-glib-dev \
    libdbusmenu-gtk3-dev \
    libgirepository1.0-dev \
    libgmock-dev \
    libgnome-panel-dev \
    libgrpc++-dev \
    libgrpc-dev \
    libgstreamer1.0-dev \
    libgtest-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libindicator3-dev \
    libmate-panel-applet-dev \
    libprotobuf-dev \
    libpulse-dev \
    librsvg2-dev \
    libspdlog-dev \
    libssl-dev \
    libtool \
    libxfce4panel-2.0-dev \
    libxfce4ui-2-dev \
    libxi-dev \
    libxmu-dev \
    libxss-dev \
    libxtst-dev \
    ninja-build \
    patchelf \
    protobuf-compiler \
    protobuf-compiler-grpc \
    qt6-base-dev \
    qt6-base-dev-tools \
    qt6-base-private-dev \
    qt6-svg-dev \
    qt6-tools-dev \
    qt6-wayland-dev \
    qt6-wayland-private-dev \
    xz-utils && \
  apt-get clean

# Rust toolchain for clang-rpc-gen (libs/rpc/tool) — installed via rustup
# rather than the distro's apt package so all container variants (jammy
# through stonking) get the same, sufficiently recent rustc/cargo instead of
# whatever each Ubuntu release happened to package.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

CMD ["/bin/bash"]
