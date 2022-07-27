FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
# RUN mkdir /workrave && \
#    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

ARG MSYS_INSTALLER=https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
# "-ExecutionPolicy", "Bypass"

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -uri "$env:MSYS_INSTALLER" -OutFile msys2.exe; \
    .\msys2.exe -y -oC:\; \
    Remove-Item msys2.exe ; \
    function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
    msys ' '; \
    msys 'pacman --noconfirm -Syuu'; \
    msys 'pacman --noconfirm -Syuu'; \
    msys 'pacman --noconfirm -S \
            git \
            mingw-w64-i686-clang \
            mingw-w64-i686-cmake \
            mingw-w64-i686-boost \
            mingw-w64-i686-lld \
            mingw-w64-i686-spdlog \
            mingw-w64-i686-ninja \
            mingw-w64-clang-x86_64-adwaita-icon-theme \
            mingw-w64-clang-x86_64-boost \
            mingw-w64-clang-x86_64-clang \
            mingw-w64-clang-x86_64-cmake \
            mingw-w64-clang-x86_64-gcc-compat \
            mingw-w64-clang-x86_64-gtkmm3 \
            mingw-w64-clang-x86_64-lld \
            mingw-w64-clang-x86_64-ninja \
            mingw-w64-clang-x86_64-openssl \
            mingw-w64-clang-x86_64-python \
            mingw-w64-clang-x86_64-python-pip \
            mingw-w64-clang-x86_64-spdlog \
            mingw-w64-clang-x86_64-jq \
            mingw-w64-clang-x86_64-uasm \
            mingw-w64-clang-x86_64-rust \
            tar \
            xz \
            zip'; \
    msys 'pacman --noconfirm -Scc';

FROM mcr.microsoft.com/windows/servercore:ltsc2022

# COPY --from=builder C:/Windows/system32/netapi32.dll C:/Windows/system32/netapi32.dll
COPY --from=builder C:/msys64 C:/msys64

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -UseBasicParsing -Uri https://files.jrsoftware.org/is/6/innosetup-6.2.0.exe -OutFile c:\innosetup.exe; \
    Start-Process ./innosetup.exe -ArgumentList '/VERYSILENT /NORESTART /NOICONS /ALLUSERS /SUPPRESSMSGBOXES /NOCANCEL /SP-' -Wait ; \
    Remove-Item -Path c:\innosetup.exe -Force;

RUN $env:PATH =  $env:PATH + ';c:\msys64\usr\bin;c:\msys64\clang64\bin;';   \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine);

ENV MSYS2_PATH_TYPE=inherit
ENV MINGW_PREFIX=/c/msys64/clang64
CMD ["bash.exe", "--login"]
