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
Ship rebuilds a Windows image on the configured Windows host when its context
changes. To build the images directly on Windows:

```sh
# In a Windows Docker shell:
docker build --isolation=process -t workrave-build:windows-msys2 windows-msys2
docker build --isolation=process -t workrave-build:windows-conan windows-conan
```

Compilation, packaging and signing stay in Workrave's release scripts.
Configure Windows SSH access and optional VM start/stop commands in a separate
Ship configuration file (see `tools/local/ship.environments.example.yaml`).
The runner has no dependency on Incus or Proxmox.

The Qt image consumes the cached Conan SDK built on Linux. Its `init-sdk.py`
relocates that SDK and builds its native `windeployqt` once.

## Recreate dependency caches locally

The images contain build tools. The Linux Conan packages and the installed
Windows Qt SDK are persistent volumes prepared by Workrave's release scripts.
To recreate either or both volumes after removal, run from the Workrave checkout:

```sh
tools/local/ship release --target windows-dependencies
```

This uses the locked recipes in `workrave-dependencies`, builds missing packages
on Linux, verifies the exported PDBs and initializes the SDK in the Windows VM.
It creates missing volumes automatically and reuses existing packages. It does
not compile, sign or publish Workrave. See Workrave's `tools/ship/README.md` for
configuration and isolated recovery-volume examples.

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

## Dependency updates

`renovate.json` configures Renovate for the base images, GitHub Actions, and the
pinned tools in `windows-conan`, `windows-msys2`, and `llvm-mingw`. Enable the
Renovate GitHub app for this repository to receive update pull requests.

Keep each `# renovate:` annotation next to its version and SHA-256 assignments.
The custom datasources select the exact upstream release asset and update its
version and checksum together; releases without a published SHA-256 are skipped.
Python updates use python.org's Windows embeddable-package metadata. Shared
llvm-mingw, Rust, and Inno Setup updates are grouped across the images. Compiler
updates still need coordination with the Conan lockfile in `workrave-dependencies`.

The checksum-pinned rustup bootstrap executable remains a manual update. MSYS2
packages and Visual Studio Build Tools use their existing rolling installers.
Renovate does not merge updates automatically; merged tool changes trigger the
existing image build workflow.
