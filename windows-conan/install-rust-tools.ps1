$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Native gettext tools generate the exercise XML; Qt translates the UI itself.
# renovate: datasource=custom.gettext-windows depName=mlocati/gettext-iconv-windows versioning=regex:^v(?<major>\d+)\.(?<minor>\d+)(?:\.(?<patch>\d+))?-v(?<build>\d+)\.(?<revision>\d+)$
$GettextRelease = 'v1.0-v1.19'
$GettextSha256 = '2b999bc37b56fa052ff98578e9cb188152009f634e3a66aa8ff263a016e9c466'
$GettextArchive = ($GettextRelease -replace '^v', 'gettext' -replace '-v', '-iconv') + '-static-64.zip'
& curl.exe --fail --location --retry 3 --silent --show-error --output C:/gettext.zip "https://github.com/mlocati/gettext-iconv-windows/releases/download/$GettextRelease/$GettextArchive"
if ($LASTEXITCODE) { throw 'gettext download failed' }
if ((Get-FileHash C:/gettext.zip -Algorithm SHA256).Hash -ne $GettextSha256) { throw 'gettext checksum mismatch' }
Expand-Archive C:/gettext.zip C:/gettext
Remove-Item C:/gettext.zip

# Use Rust's official UCRT/LLVM Windows host toolchain, matching llvm-mingw.
$env:RUSTUP_HOME = 'C:/rustup'
$env:CARGO_HOME = 'C:/rust-cargo'
$env:PATH = 'C:/llvm-mingw/bin;C:/llvm-mingw/x86_64-w64-mingw32/bin;' + $env:PATH
& C:/rust-cargo/bin/rustup.exe toolchain install "$env:RUST_VERSION-x86_64-pc-windows-gnullvm" --profile minimal
if ($LASTEXITCODE) { throw 'Rust LLVM toolchain installation failed' }
& C:/rust-cargo/bin/rustup.exe default "$env:RUST_VERSION-x86_64-pc-windows-gnullvm"
if ($LASTEXITCODE) { throw 'Rust LLVM toolchain selection failed' }
& C:/rust-cargo/bin/rustup.exe toolchain uninstall "$env:RUST_VERSION-x86_64-pc-windows-gnu"
if ($LASTEXITCODE) { throw 'Unused Rust toolchain removal failed' }
