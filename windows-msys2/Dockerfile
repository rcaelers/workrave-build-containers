FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# renovate: datasource=custom.msys2 depName=msys2/msys2-installer versioning=regex:^(?<major>\d{4})-(?<minor>\d{2})-(?<patch>\d{2})$
ARG MSYS2_RELEASE=2026-09-27
ARG MSYS2_SHA256=ad336cccfda47758b5e15cda993fbba421115cb0b126697daef1ee4dfe37209f
# renovate: datasource=custom.inno-setup depName=jrsoftware/issrc versioning=regex:^is-(?<major>\d+)_(?<minor>\d+)_(?<patch>\d+)$
ARG INNO_RELEASE=is-7_0_2
ARG INNO_SHA256=5ad54ca3def786f8f4212552e54cc6d8d61329e2d24a1cfee0571d42c2684ff1

RUN $version = $env:MSYS2_RELEASE.Replace('-', ''); \
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/msys2/msys2-installer/releases/download/$env:MSYS2_RELEASE/msys2-base-x86_64-$version.sfx.exe" -OutFile C:/msys2.exe; \
    if ((Get-FileHash C:/msys2.exe -Algorithm SHA256).Hash -ne $env:MSYS2_SHA256) { throw 'MSYS2 checksum mismatch' }; \
    & C:/msys2.exe -y -oC:/; if ($LASTEXITCODE) { exit $LASTEXITCODE }; \
    Remove-Item C:/msys2.exe

ENV MSYSTEM=CLANG64
ENV MSYS2_PATH_TYPE=inherit
ENV CHERE_INVOKING=1

COPY packages.sh C:/image/packages.sh
RUN & C:/msys64/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'; if ($LASTEXITCODE) { exit $LASTEXITCODE }
RUN & C:/msys64/usr/bin/bash.exe -lc 'pacman --noconfirm -Syuu'; if ($LASTEXITCODE) { exit $LASTEXITCODE }
RUN & C:/msys64/usr/bin/bash.exe -lc 'bash /c/image/packages.sh'; if ($LASTEXITCODE) { exit $LASTEXITCODE }

RUN $version = $env:INNO_RELEASE.Replace('is-', '').Replace('_', '.'); \
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/jrsoftware/issrc/releases/download/$env:INNO_RELEASE/innosetup-$version-x64.exe" -OutFile C:/inno.exe; \
    if ((Get-FileHash C:/inno.exe -Algorithm SHA256).Hash -ne $env:INNO_SHA256) { throw 'Inno Setup checksum mismatch' }; \
    $p = Start-Process C:/inno.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=C:\inno' -Wait -PassThru; \
    if ($p.ExitCode) { exit $p.ExitCode }; Remove-Item C:/inno.exe

# GTK's Harpoon helpers require MSVC; the main application still uses CLANG64.
COPY install-build-tools.ps1 C:/image/install-build-tools.ps1
RUN & C:/image/install-build-tools.ps1

WORKDIR C:/workspace/source
ENTRYPOINT ["C:/msys64/usr/bin/bash.exe", "-lc"]
