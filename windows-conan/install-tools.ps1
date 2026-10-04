$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# renovate: datasource=custom.llvm-mingw-windows depName=mstorsjo/llvm-mingw versioning=regex:^(?<major>\d{8})$
$LlvmMingwVersion = '20260922'
$LlvmMingwSha256 = 'e3ad77d117a4bea19a7a3b333341824d79a5a371004a10e25b8504e7b3047666'
# renovate: datasource=custom.cmake-windows depName=Kitware/CMake
$CmakeVersion = '4.2.3'
$CmakeSha256 = 'eb4ebf5155dbb05436d675706b2a08189430df58904257ae5e91bcba4c86933c'
# renovate: datasource=custom.ninja-windows depName=ninja-build/ninja
$NinjaVersion = '1.13.1'
$NinjaSha256 = '26a40fa8595694dec2fad4911e62d29e10525d2133c9a4230b66397774ae25bf'
# renovate: datasource=custom.git-windows depName=git-for-windows/git versioning=regex:^v(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\.windows\.(?<build>\d+)$
$GitRelease = 'v2.53.0.windows.1'
$GitSha256 = '82b562c918ec87b2ef5316ed79bb199e3a25719bb871a0f10294acf21ebd08cd'
# renovate: datasource=custom.python-windows depName=python
$PythonVersion = '3.14.0'
$PythonSha256 = '8d4d3590c10449d78aa4375f534e6d5f3027d67fdc362dd1a882279db6f90fdf'
# renovate: datasource=custom.inno-setup depName=jrsoftware/issrc versioning=regex:^is-(?<major>\d+)_(?<minor>\d+)_(?<patch>\d+)$
$InnoRelease = 'is-7_0_2'
$InnoSha256 = '5ad54ca3def786f8f4212552e54cc6d8d61329e2d24a1cfee0571d42c2684ff1'

function Download($url, $path, $sha256) {
    Write-Host "Downloading $url"
    & curl.exe --fail --location --retry 3 --silent --show-error --output $path $url
    if ($LASTEXITCODE) { throw "Download failed: $url" }
    if ((Get-FileHash $path -Algorithm SHA256).Hash -ne $sha256) {
        throw "Checksum mismatch: $url"
    }
}

function Install-Zip($url, $name, $sha256, $nested) {
    Download $url C:/download.zip $sha256
    Expand-Archive C:/download.zip C:/unpack
    if ($nested) {
        Move-Item C:/unpack/$nested C:/$name
        Remove-Item C:/unpack
    } else {
        Move-Item C:/unpack C:/$name
    }
    Remove-Item C:/download.zip
}

Install-Zip "https://github.com/mstorsjo/llvm-mingw/releases/download/$LlvmMingwVersion/llvm-mingw-$LlvmMingwVersion-ucrt-x86_64.zip" llvm-mingw $LlvmMingwSha256 "llvm-mingw-$LlvmMingwVersion-ucrt-x86_64"
Install-Zip "https://github.com/Kitware/CMake/releases/download/v$CmakeVersion/cmake-$CmakeVersion-windows-x86_64.zip" cmake $CmakeSha256 "cmake-$CmakeVersion-windows-x86_64"
Install-Zip "https://github.com/ninja-build/ninja/releases/download/v$NinjaVersion/ninja-win.zip" ninja $NinjaSha256 $null
$GitVersion = $GitRelease -replace '^v', '' -replace '\.windows\.1$', '' -replace '\.windows\.', '.'
Install-Zip "https://github.com/git-for-windows/git/releases/download/$GitRelease/MinGit-$GitVersion-64-bit.zip" git $GitSha256 $null
Install-Zip "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-amd64.zip" python $PythonSha256 $null
# Enable script-directory imports for the native release scripts.
$PythonPathFile = Get-Item C:/python/python*._pth
(Get-Content $PythonPathFile) -replace '#import site', 'import site' | Set-Content $PythonPathFile

$InnoVersion = $InnoRelease -replace '^is-', '' -replace '_', '.'
Download "https://github.com/jrsoftware/issrc/releases/download/$InnoRelease/innosetup-$InnoVersion-x64.exe" C:/inno.exe $InnoSha256
$p = Start-Process C:/inno.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=C:\inno' -Wait -PassThru
if ($p.ExitCode) { throw "Inno Setup installation failed: $($p.ExitCode)" }
Remove-Item C:/inno.exe

Download 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-gnu/rustup-init.exe' C:/rustup-init.exe '6d5b5709addc0122c916d8c810da8d8a7b086a5d64fa805ef404d506392aadc8'
$env:RUSTUP_HOME = 'C:/rustup'
$env:CARGO_HOME = 'C:/rust-cargo'
& C:/rustup-init.exe -y --no-modify-path --default-host x86_64-pc-windows-gnu --default-toolchain $env:RUST_VERSION --profile minimal
if ($LASTEXITCODE) { throw "Rust installation failed: $LASTEXITCODE" }
Remove-Item C:/rustup-init.exe
