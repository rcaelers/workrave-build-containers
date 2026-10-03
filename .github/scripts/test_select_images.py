import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("select_images", Path(__file__).with_name("select-images.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ImageSelectionTests(unittest.TestCase):
    def test_unrelated_changes_build_nothing(self):
        self.assertEqual(module.select_images(["README.md", "LICENSE"]), {"linux": [], "windows": []})

    def test_each_context_selects_only_its_image(self):
        for image in (*module.LINUX, *module.WINDOWS):
            with self.subTest(image=image):
                expected = {"linux": [], "windows": []}
                expected["linux" if image in module.LINUX else "windows"] = [image]
                self.assertEqual(module.select_images([image + "/nested/input"]), expected)

    def test_changes_in_multiple_contexts(self):
        self.assertEqual(module.select_images(["llvm-mingw/Dockerfile", "windows-conan/init-sdk.py"]),
                         {"linux": ["llvm-mingw"], "windows": ["windows-conan"]})

    def test_windows_workflow_changes_only_rebuild_windows(self):
        self.assertEqual(module.select_images([".github/workflows/build-windows-image.yml"]),
                         {"linux": [], "windows": list(module.WINDOWS)})

    def test_linux_workflow_changes_only_rebuild_linux(self):
        self.assertEqual(module.select_images([".github/workflows/build-linux-image.yml"]),
                         {"linux": list(module.LINUX), "windows": []})

    def test_shared_workflow_changes_rebuild_all(self):
        self.assertEqual(module.select_images([".github/workflows/publish.yaml"]),
                         module.select_images(requested="all"))

    def test_manual_dispatch_ignores_changed_files(self):
        self.assertEqual(module.select_images(["ubuntu-noble/Dockerfile"], requested="windows-conan"),
                         {"linux": [], "windows": ["windows-conan"]})
        self.assertEqual(module.select_images(requested="all"),
                         {"linux": list(module.LINUX), "windows": list(module.WINDOWS)})

    def test_invalid_manual_image_is_rejected(self):
        with self.assertRaises(ValueError):
            module.select_images(requested="unknown")

    def test_new_branch_builds_all_images(self):
        self.assertIsNone(module.push_paths({"before": "0" * 40, "after": "1" * 40}))

    def test_push_includes_all_commits_and_both_sides_of_renames(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            def git(*args):
                return subprocess.check_output(["git", "-C", str(root), *args], stderr=subprocess.DEVNULL).decode().strip()
            def commit():
                git("add", ".")
                git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-m", "test")
                return git("rev-parse", "HEAD")
            git("init")
            (root / "windows-msys2").mkdir()
            (root / "windows-conan").mkdir()
            (root / "windows-msys2/input").write_text("unchanged content")
            before = commit()
            (root / "windows-msys2/input").rename(root / "windows-conan/input")
            commit()
            (root / "llvm-mingw").mkdir()
            (root / "llvm-mingw/Dockerfile").write_text("FROM ubuntu:26.04")
            after = commit()
            # Run git in the fixture without changing the process-wide directory.
            check_output = subprocess.check_output
            with patch.object(module.subprocess, "check_output", side_effect=lambda args: check_output(args, cwd=root)):
                paths = module.push_paths({"before": before, "after": after})
            self.assertEqual(module.select_images(paths),
                             {"linux": ["llvm-mingw"], "windows": list(module.WINDOWS)})


if __name__ == "__main__":
    unittest.main()
