FROM ubuntu:bionic

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y \
    wget \
    gpg && \
  wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
  echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
  apt-get update -y && \
  rm /usr/share/keyrings/kitware-archive-keyring.gpg && \
  apt-get install kitware-archive-keyring

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y \
    autoconf \
    autoconf-archive \
    automake \
    autopoint \
    build-essential \
    cmake \
    debhelper \
    devscripts \
    dh-autoreconf \
    gcc-8 \
    g++-8 \
    gettext \
    git \
    gobject-introspection \
    gsettings-desktop-schemas-dev \
    intltool \
    jq \
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
    libgstreamer1.0-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libindicator3-dev \
    libmate-panel-applet-dev \
    libpanel-applet-dev \
    libpulse-dev \
    libqt5svg5-dev \
    libqt5x11extras5-dev \
    libssl-dev \
    libtool \
    libxfce4panel-2.0-dev \
    libxi-dev \
    libxmu-dev \
    libxss-dev \
    libxtst-dev \
    ninja-build \
    python3-pip \
    python3-setuptools \
    qtbase5-dev \
    qtbase5-private-dev \
    qttools5-dev-tools \
    xfce4-panel-dev && \
  apt-get clean

RUN pip3 install --upgrade pip
RUN pip3 install Jinja2

RUN ln -s /usr/bin/ninja /usr/bin/ninja-build

CMD ["/bin/bash"]
