"""Initialize a relocatable Conan SDK in a persistent Windows Docker volume."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    root = args.destination
    if (root / ".ready").is_file():
        print(f"Reusing native Qt SDK: {root}", flush=True)
        return
    if root.exists():
        shutil.rmtree(root)
    root.mkdir(parents=True)
    with tarfile.open(args.archive) as archive:
        archive.extractall(root, filter="data")
    manifest = json.loads((root / "manifest.json").read_text())
    compiler = subprocess.check_output(["x86_64-w64-mingw32-clang", "--version"], text=True)
    # Host OS differs; LLVM's version and release must match the package compiler.
    if compiler.splitlines()[0] != manifest["compiler"].splitlines()[0]:
        raise RuntimeError("Native compiler does not match the Conan SDK compiler")
    for path in root.rglob("*"):
        if path.is_file() and path.suffix in (".cmake", ".pc", ".prl"):
            path.write_text(path.read_text().replace("@WORKRAVE_SDK_ROOT@", root.as_posix()))
    bins = [p / "bin" for p in (root / "packages").iterdir()]
    os.environ["PATH"] = os.pathsep.join(map(str, bins)) + os.pathsep + os.environ["PATH"]
    build = root / "build/windeployqt"
    subprocess.run(["cmake", "-S", str(root / "src/windeployqt"), "-B", str(build), "-G", "Ninja",
                    f"-DCMAKE_TOOLCHAIN_FILE={root / 'toolchain.cmake'}", "-DCMAKE_BUILD_TYPE=Release",
                    f"-DCMAKE_INSTALL_PREFIX={root}"], check=True)
    subprocess.run(["cmake", "--build", str(build), "--parallel", "4"], check=True)
    subprocess.run(["cmake", "--install", str(build)], check=True)
    (root / ".ready").write_text(manifest["cache_key"] + "\n")
    print(f"Cached native Qt SDK: {root}", flush=True)


if __name__ == "__main__":
    main()
