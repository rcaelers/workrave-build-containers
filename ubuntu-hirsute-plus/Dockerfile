FROM ubuntu:hirsute

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  echo 'Acquire::Languages "none";' | tee /etc/apt/apt.conf.d/99translations > /dev/null && \
  apt-get update -y && \
  apt-get install -y curl software-properties-common && \
  curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
  add-apt-repository "deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-13 main" && \
  apt-get update -y && \
  apt-get --no-install-recommends install -y \
    autoconf \
    autoconf-archive \
    automake \
    autopoint \
    build-essential \
    clang-13 \
    cmake \
    debhelper \
    devscripts \
    dh-autoreconf \
    g++-10 \
    gcc-10 \
    gettext \
    git \
    gobject-introspection \
    gsettings-desktop-schemas-dev \
    intltool \
    jq \
    libayatana-indicator3-dev \
    libboost-chrono-dev \
    libboost-context-dev \
    libboost-coroutine-dev \
    libboost-date-time-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-log-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libdbusmenu-glib-dev \
    libdbusmenu-gtk3-dev \
    libgirepository1.0-dev \
    libgnome-panel-dev \
    libgstreamer1.0-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libindicator3-dev \
    libmate-panel-applet-dev \
    libpulse-dev \
    libqt5svg5-dev \
    libqt5x11extras5-dev \
    libspdlog-dev \
    libssl-dev \
    libtool \
    libxfce4panel-2.0-dev \
    libxi-dev \
    libxmu-dev \
    libxss-dev \
    libxtst-dev \
    ninja-build \
    nodejs \
    npm \
    python3-pip \
    python3-setuptools \
    python3-paramiko \
    python3-jinja2 \
    qtbase5-dev \
    qtbase5-dev-tools \
    qtbase5-private-dev \
    qttools5-dev \
    qttools5-dev-tools && \
  apt-get clean

CMD ["/bin/bash"]
