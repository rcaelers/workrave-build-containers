$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

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

Install-Zip 'https://github.com/mstorsjo/llvm-mingw/releases/download/20260922/llvm-mingw-20260922-ucrt-x86_64.zip' llvm-mingw 'e3ad77d117a4bea19a7a3b333341824d79a5a371004a10e25b8504e7b3047666' llvm-mingw-20260922-ucrt-x86_64
Install-Zip 'https://github.com/Kitware/CMake/releases/download/v4.2.3/cmake-4.2.3-windows-x86_64.zip' cmake 'eb4ebf5155dbb05436d675706b2a08189430df58904257ae5e91bcba4c86933c' cmake-4.2.3-windows-x86_64
Install-Zip 'https://github.com/ninja-build/ninja/releases/download/v1.13.1/ninja-win.zip' ninja '26a40fa8595694dec2fad4911e62d29e10525d2133c9a4230b66397774ae25bf' $null
Install-Zip 'https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.1/MinGit-2.53.0-64-bit.zip' git '82b562c918ec87b2ef5316ed79bb199e3a25719bb871a0f10294acf21ebd08cd' $null
Install-Zip 'https://www.python.org/ftp/python/3.14.0/python-3.14.0-embed-amd64.zip' python '8d4d3590c10449d78aa4375f534e6d5f3027d67fdc362dd1a882279db6f90fdf' $null
# Enable script-directory imports for the native release scripts.
(Get-Content C:/python/python314._pth) -replace '#import site', 'import site' | Set-Content C:/python/python314._pth

Download 'https://github.com/jrsoftware/issrc/releases/download/is-7_0_2/innosetup-7.0.2-x64.exe' C:/inno.exe '5ad54ca3def786f8f4212552e54cc6d8d61329e2d24a1cfee0571d42c2684ff1'
$p = Start-Process C:/inno.exe -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /DIR=C:\inno' -Wait -PassThru
if ($p.ExitCode) { throw "Inno Setup installation failed: $($p.ExitCode)" }
Remove-Item C:/inno.exe

Download 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-gnu/rustup-init.exe' C:/rustup-init.exe '6d5b5709addc0122c916d8c810da8d8a7b086a5d64fa805ef404d506392aadc8'
$env:RUSTUP_HOME = 'C:/rustup'
$env:CARGO_HOME = 'C:/rust-cargo'
& C:/rustup-init.exe -y --no-modify-path --default-host x86_64-pc-windows-gnu --default-toolchain 1.98.1 --profile minimal
if ($LASTEXITCODE) { throw "Rust installation failed: $LASTEXITCODE" }
Remove-Item C:/rustup-init.exe
