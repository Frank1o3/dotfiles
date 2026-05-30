#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path
import sys

CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync", "fish"]


def get_git_changes():
    # Detects changed files (staged, unstaged, and untracked)
    status = subprocess.check_output(["git", "status", "--porcelain"]).decode()
    # Extract paths, ignoring the status prefix (e.g., ' M ', '?? ')
    return [line[3:].strip() for line in status.splitlines()]


def main():
    if len(sys.argv) < 2:
        print("Usage: ./release.py 'commit message'")
        sys.exit(1)

    message = sys.argv[1]
    changes = get_git_changes()

    if not changes:
        print("No changes detected in git.")
        return

    any_updates = False

    for cfg in CONFIGS:
        cfg_path = Path(cfg)
        if not cfg_path.exists():
            continue

        # Logic Fix: Check if this folder OR any sub-files have changed
        has_changes = any(path.startswith(cfg + "/") for path in changes)

        if not has_changes:
            print(f"[-] {cfg}: No changes, skipping.")
            continue

        # 1. Update Version
        ver_file = cfg_path / ".version"
        version = 1
        if ver_file.exists():
            try:
                version = json.loads(ver_file.read_text())["version"] + 1
            except:
                pass

        # 2. Capture the "State of Truth"
        # We index EVERY file currently in the folder.
        # This ensures the update script knows these files are valid.
        all_files = [
            str(p)
            for p in cfg_path.rglob("*")
            if p.is_file() and p.name not in [".version", ".manifest.json"]
        ]

        # Safety Check: Never push an empty file list if the folder isn't actually empty
        if not all_files and any(cfg_path.iterdir()):
            print(
                f"⚠️  {cfg}: manifest list is empty but folder is not! Skipping for safety."
            )
            continue

        # 3. Write Manifest
        manifest = {"version": version, "message": message, "files": all_files}

        (cfg_path / ".manifest.json").write_text(json.dumps(manifest, indent=2))
        ver_file.write_text(json.dumps({"version": version}, indent=2))
        print(f"[+] {cfg}: Bumped to v{version} ({len(all_files)} files tracked)")
        any_updates = True

    if any_updates:
        # Git ops
        subprocess.run(["git", "add", "."])
        subprocess.run(["git", "commit", "-m", f"release: {message}"])
        subprocess.run(["git", "push"])
        print("\n✅ Pushed to GitHub.")
    else:
        print("\nℹ️ No manifests were updated.")


if __name__ == "__main__":
    main()
