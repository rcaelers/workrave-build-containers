ARG UBUNTU_RELEASE=26.04
FROM docker.io/library/rust:1.98.1-slim-bookworm AS rust

FROM docker.io/library/ubuntu:${UBUNTU_RELEASE}

COPY --from=rust /usr/local/cargo /opt/rust/cargo
COPY --from=rust /usr/local/rustup /opt/rust/rustup
ENV CARGO_HOME=/cache/cargo
ENV RUSTUP_HOME=/opt/rust/rustup

# renovate: datasource=custom.llvm-mingw-linux depName=mstorsjo/llvm-mingw versioning=regex:^(?<major>\d{8})$
ARG LLVM_MINGW_VERSION=20260922
ARG LLVM_MINGW_SHA256=bb7bb7654b33d5aa8712acb837c963b2e0c56352560c76105270a3268c665c21
# renovate: datasource=pypi depName=conan
ARG CONAN_VERSION=2.32.0
# renovate: datasource=custom.dump-syms depName=mozilla/dump_syms
ARG DUMP_SYMS_VERSION=2.3.9
ARG DUMP_SYMS_SHA256=0fc852a86b00337407d9d423cc388a24c3b489ccaaedcf92623cad57af5ca8ad

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gettext \
    git \
    jq \
    libgl1-mesa-dev \
    libtool \
    nasm \
    ninja-build \
    patch \
    perl \
    pkg-config \
    python3 \
    python3-venv \
    wine \
    xauth \
    xvfb \
    xz-utils && \
  rm -rf /var/lib/apt/lists/*

RUN \
  curl -fL --retry 3 \
    "https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-x86_64.tar.xz" \
    -o /tmp/llvm-mingw.tar.xz && \
  echo "${LLVM_MINGW_SHA256}  /tmp/llvm-mingw.tar.xz" | sha256sum -c - && \
  mkdir -p /opt/llvm-mingw && \
  tar -xJf /tmp/llvm-mingw.tar.xz -C /opt/llvm-mingw --strip-components=1 && \
  rm /tmp/llvm-mingw.tar.xz

RUN \
  python3 -m venv /opt/conan && \
  /opt/conan/bin/pip install --no-cache-dir "conan==${CONAN_VERSION}"

RUN \
  curl -fL --retry 3 \
    "https://github.com/mozilla/dump_syms/releases/download/v${DUMP_SYMS_VERSION}/dump_syms-x86_64-unknown-linux-gnu.tar.xz" \
    -o /tmp/dump-syms.tar.xz && \
  echo "${DUMP_SYMS_SHA256}  /tmp/dump-syms.tar.xz" | sha256sum -c - && \
  mkdir -p /opt/dump-syms && \
  tar -xJf /tmp/dump-syms.tar.xz -C /opt/dump-syms --strip-components=1 && \
  rm /tmp/dump-syms.tar.xz

ENV PATH="/opt/rust/cargo/bin:/opt/conan/bin:/opt/llvm-mingw/bin:/opt/dump-syms:${PATH}"
ENV CONAN_HOME=/cache/conan

WORKDIR /work

# renovate: datasource=custom.inno-setup depName=jrsoftware/issrc versioning=regex:^is-(?<major>\d+)_(?<minor>\d+)_(?<patch>\d+)$
ARG INNO_SETUP_TAG=is-7_0_2
ARG INNO_SETUP_SHA256=5ad54ca3def786f8f4212552e54cc6d8d61329e2d24a1cfee0571d42c2684ff1

RUN \
  INNO_SETUP_VERSION="$(printf '%s' "${INNO_SETUP_TAG#is-}" | tr _ .)" && \
  curl -fL --retry 3 \
    "https://github.com/jrsoftware/issrc/releases/download/${INNO_SETUP_TAG}/innosetup-${INNO_SETUP_VERSION}-x64.exe" \
    -o /tmp/inno.exe && \
  echo "${INNO_SETUP_SHA256}  /tmp/inno.exe" | sha256sum -c - && \
  WINEPREFIX=/tmp/wine-inno WINEDEBUG=-all xvfb-run -a \
    wine /tmp/inno.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /ALLUSERS '/DIR=Z:\\opt\\inno' && \
  test -f /opt/inno/ISCC.exe && \
  rm /tmp/inno.exe

RUN rm -rf /tmp/wine-inno

COPY iscc /usr/local/bin/iscc
RUN chmod +x /usr/local/bin/iscc
ENV WINEDEBUG=-all
ENV WINEPREFIX=/cache/wine

# renovate: datasource=custom.protoc depName=protocolbuffers/protobuf
ARG PROTOC_VERSION=35.1
ARG PROTOC_SHA256=6930ebf62bd4ea607b98fff052596c6ee564b9835b4ce172c75a3f53ae9d91b7
RUN \
  curl -fL --retry 3 \
    "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
    -o /tmp/protoc.zip && \
  echo "${PROTOC_SHA256}  /tmp/protoc.zip" | sha256sum -c - && \
  python3 -c "import zipfile; zipfile.ZipFile('/tmp/protoc.zip').extractall('/opt/protoc')" && \
  chmod +x /opt/protoc/bin/protoc && \
  rm /tmp/protoc.zip

RUN mkdir -m 700 /tmp/wine-runtime
ENV XDG_RUNTIME_DIR=/tmp/wine-runtime

# Conan's libxml2 recipe names this Windows SDK import library Bcrypt.
# Provide its canonical Windows spelling on Linux's case-sensitive filesystem.
RUN \
  for target in x86_64 aarch64; do \
    ln -s libbcrypt.a /opt/llvm-mingw/${target}-w64-mingw32/lib/libBcrypt.a; \
  done
