"""Select container images whose build inputs changed in a GitHub push."""

import json
import os
from pathlib import Path
import subprocess


LINUX = (
    "debian-testing", "ubuntu-pbuilder", "ubuntu-cross-aarch64", "ubuntu-jammy",
    "ubuntu-noble", "ubuntu-resolute", "ubuntu-stonking", "llvm-mingw",
)
WINDOWS = ("windows-msys2", "windows-conan")
SHARED = {".github/workflows/publish.yaml", ".github/scripts/select-images.py", ".gitattributes"}
LINUX_SHARED = {".github/workflows/build-linux-image.yml"}
WINDOWS_SHARED = {".github/workflows/build-windows-image.yml", ".github/scripts/context-hash.py"}


def select_images(paths=(), requested=None):
    if requested is not None:
        if requested not in ("all", *LINUX, *WINDOWS):
            raise ValueError(f"Unknown image: {requested}")
        return {
            "linux": [image for image in LINUX if requested in ("all", image)],
            "windows": [image for image in WINDOWS if requested in ("all", image)],
        }
    paths = set(paths)
    return {
        "linux": [image for image in LINUX if paths & (SHARED | LINUX_SHARED)
                  or any(path.startswith(image + "/") for path in paths)],
        "windows": [image for image in WINDOWS if paths & (SHARED | WINDOWS_SHARED)
                    or any(path.startswith(image + "/") for path in paths)],
    }


def push_paths(event):
    before, after = event["before"], event["after"]
    if before == "0" * 40:
        # A new branch has no previous tree; all current contexts are new.
        return None
    output = subprocess.check_output([
        "git", "diff", "--name-only", "--no-renames", "-z", before, after,
    ])
    return [os.fsdecode(path) for path in output.split(b"\0") if path]


def main():
    if os.environ["GITHUB_EVENT_NAME"] == "workflow_dispatch":
        selected = select_images(requested=os.environ.get("REQUESTED_IMAGE", "all"))
    else:
        paths = push_paths(json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text()))
        selected = select_images(paths) if paths is not None else select_images(requested="all")
    with Path(os.environ["GITHUB_OUTPUT"]).open("a") as output:
        for platform, images in selected.items():
            output.write(f"{platform}={json.dumps(images, separators=(',', ':'))}\n")
    print(json.dumps(selected, indent=2))


if __name__ == "__main__":
    main()
