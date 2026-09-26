# ubuntu-cross-aarch64

An **amd64** Ubuntu image which builds Workrave's **aarch64** AppImage with
native GCC cross-compilers, CMake, Ninja, Rust/libclang and linuxdeploy.
The published tag is `ghcr.io/rcaelers/workrave-build:ubuntu-cross-aarch64`.
It stays the same when the Ubuntu base release is updated.

The Dockerfile's `UBUNTU_RELEASE` argument selects the Ubuntu release
(currently `resolute`). Advance its default for each Ubuntu update; both
the native and ARM64 package sources follow that release automatically.
The release also determines the versions of the libraries in the AppImage.

## Build

From this repository's root:

```sh
podman build --platform linux/amd64 \
  --build-arg UBUNTU_RELEASE=resolute \
  --build-arg GIT_COMMIT_HASH="$(git rev-parse HEAD)" \
  -t ghcr.io/rcaelers/workrave-build:ubuntu-cross-aarch64 \
  ubuntu-cross-aarch64
```

The publishing workflow builds only the amd64 variant. It enables ARM64
binfmt support for package post-install scripts during image creation.

## Use

The Workrave `ship` pipeline selects this image automatically for the ARM64
AppImage on an amd64 container host. `linux.cross_image` overrides the image
tag; `container.image_repository` selects the repository. ARM64 hosts keep
using their native Ubuntu image.

For a direct build, mount a Workrave checkout and an artifact directory:

```sh
podman run --rm --platform linux/amd64 \
  -v "$PWD":/workspace/source \
  -v "$PWD/_deploy":/workspace/deploy \
  -e WORKRAVE_ENV=local -e CONF_CONFIGURATION=Release -e CONF_APPIMAGE=1 \
  ghcr.io/rcaelers/workrave-build:ubuntu-cross-aarch64 \
  /workspace/source/tools/ci/build.sh
```

The image supplies `CONF_TOOLCHAIN_FILE` and `CONF_TARGET_ARCH`. No FUSE,
extra container capabilities or host binfmt registration are required to
build Workrave with the completed image. Build scripts and CMake files must
include the cross-AppImage support; changing only the image on an older
Workrave revision is insufficient.

## Host and target tools

- C/C++ compilation and linking use `aarch64-linux-gnu-gcc/g++` on amd64.
- Cargo and libclang generate RPC bindings on amd64, using the target triple
  and include paths supplied by CMake. Do not export a target `CC` globally:
  Rust's build dependencies are host code.
- `pkg-config` sees ARM64 and architecture-independent metadata only.
- Ubuntu's GObject Introspection wrappers use the cross compiler and, when
  needed, `aarch64-linux-gnu-cross-exe-wrapper` to run a target helper.
- `ldd`, `gtk-query-immodules-3.0` and `gdk-pixbuf-query-loaders` wrappers use
  explicit QEMU calls for the target loader/cache generators.
- Workrave's `install/strip` target uses the cross strip tool. Cross packaging
  disables linuxdeploy's bundled, host-only strip; Ubuntu's runtime libraries
  are already stripped. linuxdeploy and SquashFS compression run on amd64,
  with an explicitly selected aarch64 AppImage runtime.

Build and output directories and deployed AppImage filenames include the
target architecture, so native and cross artifacts cannot overwrite each
other. Unit tests, if enabled, use CMake's cross-compiling emulator.

## Validation after an Ubuntu update

Build a complete AppImage, inspect it and its contained ELF files with
`file`/`readelf`, and run it on ARM64 Linux (or under QEMU with an X server).
Check GTK image loaders, GSettings, GNOME introspection, and the enabled
desktop integrations. Also exercise the introspection wrappers without
host binfmt support. The small amount of target execution is intentional;
the compilers and packagers must remain amd64 programs.
