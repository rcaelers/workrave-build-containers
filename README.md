# Workrave build containers

Docker image definitions for Workrave's release builds. Published tags use
`ghcr.io/rcaelers/workrave-build:<image>`.

## Windows builds

| Image | Environment |
| --- | --- |
| `windows-msys2` | MSYS2 CLANG64 and GTKmm 3; MSVC for Harpoon helpers |
| `windows-conan` | Native llvm-mingw, Rust gnullvm, Python, gettext and Inno Setup; no MSYS2 |
| `llvm-mingw` | Linux amd64 compiler and Conan tools for the Windows Qt dependencies |

The Windows images use Windows Server Core LTSC 2025 and are built on the
GitHub-hosted `windows-2025` runner. Workrave runs them as process-isolated
containers in its Windows VM. They cannot be built by a Linux daemon.
The `llvm-mingw` image runs on Linux amd64; Conan recipes, profiles and the
lockfile remain in [workrave-dependencies](https://github.com/rcaelers/workrave-dependencies/tree/main/conan).

From this repository's root, build the Windows images in Windows PowerShell:

```powershell
docker build --isolation=process -t workrave-build:windows-msys2 windows-msys2
docker build --isolation=process -t workrave-build:windows-conan windows-conan
```

Build the Linux compiler image on a Linux amd64 Docker or Podman host:

```sh
docker build -t workrave-build:llvm-mingw llvm-mingw
```

Workrave's release pipeline uses `windows.containers_dir` for these Windows
build contexts and `windows.dependencies_dir` for the separate Conan checkout.
It rebuilds a Windows image on the VM when its context changes. To prepare
only an image from macOS or Linux using Workrave's existing SSH/Incus runner:

```sh
python3 /path/to/workrave/tools/local/run-windows-container.py \
  --host forge --vm win11-vm --docker C:/path/to/docker.exe \
  --image workrave-build:windows-conan \
  --image-context /path/to/workrave-build-containers/windows-conan --image-only
```

Compilation, packaging and signing stay in Workrave's release scripts.
The Qt image consumes the cached Conan SDK built on Linux. Its `init-sdk.py`
relocates that SDK and builds its native `windeployqt` once.

## Automatic and manual builds

The **Workrave build containers** workflow publishes to GHCR on pushes to
`master`. It compares the complete push (`before` to `after`), including all
commits, and builds only images whose context files changed. An unrelated
README or license change builds nothing. Changes to the Linux build workflow
rebuild the Linux images; changes to the Windows build workflow rebuild the
Windows images. Shared orchestration or image-selection changes rebuild all
images. There is no scheduled rebuild.

Use **Actions > Workrave build containers > Run workflow** to force a rebuild.
Select a single image or `all` (the default). This works without file changes.
The Windows workflow applies the same context hash as Workrave's release
runner, so a pulled published image can be reused without an automatic rebuild.

`ubuntu-cross-aarch64` and `llvm-mingw` are Linux amd64-only images. The other
published Linux images are built for both amd64 and arm64.
