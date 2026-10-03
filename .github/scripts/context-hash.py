"""Match Workrave's Windows runner image-context hash on any host OS."""

import hashlib
from pathlib import Path
import sys


def context_hash(root):
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*"), key=lambda path: path.relative_to(root).as_posix()):
        if path.is_file():
            digest.update(path.relative_to(root).as_posix().encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()


if __name__ == "__main__":
    print(context_hash(Path(sys.argv[1])))
