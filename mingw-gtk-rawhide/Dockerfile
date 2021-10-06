FROM fedora:rawhide

MAINTAINER Rob Caelers <rob.caelers@gmail.com>

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN echo "%_install_langs all" >/etc/rpm/macros.image-language-conf && \
    dnf clean all && \
    dnf -y update && \
    dnf -y install \
                bzip2 \
                clang \
                cmake \
                dos2unix \
                gcc \
                gettext \
                git \
                gobject-introspection-devel \
                gtk-update-icon-cache \
                innoextract \
                jq \
                lld \
                mingw32-gcc \
                mingw32-gcc-c++ \
                mingw64-boost \
                mingw64-gcc \
                mingw64-gcc-c++ \
                mingw64-gettext \
                mingw64-gtkmm30 \
                mingw64-librsvg2 \
                mingw64-adwaita-icon-theme \
                ninja-build \
                python3-jinja2 \
                python3-pip \
                tar \
                which \
                wine-core.i686 \
                xz && \
    dnf -y clean all

RUN mkdir -p /workspace

RUN cd /workspace && \
    curl -O http://files.jrsoftware.org/is/6/innosetup-6.2.0.exe && \
    innoextract -d /workspace/inno ./innosetup-6.2.0.exe && \
    rm ./innosetup-6.2.0.exe

RUN cd /workspace && \
    curl -O https://snapshots.workrave.org/prebuilt/workrave-prebuilt-windows-vs2015.tar.xz && \
    tar xvfJ ./workrave-prebuilt-windows-vs2015.tar.xz && \
    rm ./workrave-prebuilt-windows-vs2015.tar.xz && \
    ln -s workrave-prebuilt-windows-vs2015 prebuilt

RUN cd /workspace && \
    git clone https://github.com/tpoechtrager/wclang.git && \
    cd /workspace/wclang && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ && \
    make && \
    make install && \
    rm -rf /workspace/wclang

RUN cd /workspace && \
    curl -OL https://github.com/mozilla/dump_syms/releases/download/v0.0.7/dump_syms-linux-x86_64.tar.gz && \
    tar xvfz dump_syms-linux-x86_64.tar.gz && \
    cp -a dump_syms-linux-x86_64/dump_syms /usr/local/bin && \
    rm -rf dump_syms-linux-x86_64.tar.gz dump_syms-linux-x86_64
