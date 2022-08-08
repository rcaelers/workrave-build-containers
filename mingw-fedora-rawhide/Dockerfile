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
                cargo \
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
                mingw32-boost \
                mingw32-boost-static \
                mingw32-gcc \
                mingw32-gcc-c++ \
                mingw64-adwaita-icon-theme \
                mingw64-boost \
                mingw64-boost-static \
                mingw64-gcc \
                mingw64-gcc-c++ \
                mingw64-gettext \
                mingw64-gtkmm30 \
                mingw64-librsvg2 \
                mingw64-qt6-qtbase \
                mingw64-qt6-qtimageformats \
                mingw64-qt6-qtsvg \
                mingw64-qt6-qttools \
                ninja-build \
                python3-jinja2 \
                python3-pip \
                rust \
                tar \
                which \
                wine-core.i686 \
                xz \
                zstd && \
    dnf -y clean all

RUN mkdir -p /workspace

RUN cd /workspace && \
    curl -O http://files.jrsoftware.org/is/6/innosetup-6.2.1.exe && \
    innoextract -d /workspace/inno ./innosetup-6.2.1.exe && \
    rm ./innosetup-6.2.1.exe

RUN cd /workspace && \
    curl -OL https://github.com/mozilla/dump_syms/releases/download/v1.0.1/dump_syms-linux-x86_64.tar.gz && \
    tar xvfz dump_syms-linux-x86_64.tar.gz && \
    cp -a dump_syms-linux-x86_64/dump_syms /usr/local/bin && \
    rm -rf dump_syms-linux-x86_64.tar.gz dump_syms-linux-x86_64
