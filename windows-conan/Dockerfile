FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Match the compiler that builds the locked Conan packages on Linux.
# renovate: datasource=github-releases depName=rust-lang/rust
ARG RUST_VERSION=1.98.1
COPY install-tools.ps1 C:/image/install-tools.ps1
RUN & C:/image/install-tools.ps1

COPY install-rust-tools.ps1 C:/image/install-rust-tools.ps1
RUN & C:/image/install-rust-tools.ps1

ENV LLVM_MINGW_ROOT=C:/llvm-mingw
ENV RUSTUP_HOME=C:/rustup
ENV PATH="C:/python;C:/cmake/bin;C:/ninja;C:/git/cmd;C:/gettext/bin;C:/llvm-mingw/bin;C:/llvm-mingw/x86_64-w64-mingw32/bin;C:/rust-cargo/bin;C:/Windows/system32;C:/Windows/system32/WindowsPowerShell/v1.0;C:/Windows"
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNULLVM_LINKER=C:/llvm-mingw/bin/x86_64-w64-mingw32-clang.exe
ENV CC=C:/llvm-mingw/bin/x86_64-w64-mingw32-clang.exe
ENV CXX=C:/llvm-mingw/bin/x86_64-w64-mingw32-clang++.exe
ENV AR=C:/llvm-mingw/bin/llvm-ar.exe
ENV LIBGIT2_NO_PKG_CONFIG=1
ENV LIBGIT2_STATIC=1

COPY init-sdk.py C:/image/init-sdk.py

WORKDIR C:/workspace/source
ENTRYPOINT ["C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-NoProfile", "-NonInteractive", "-Command"]
