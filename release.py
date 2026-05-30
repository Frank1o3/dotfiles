#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path
import sys

CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def get_git_changes():
    # Checks for any changes (staged or unstaged)
    status = subprocess.check_output(["git", "status", "--porcelain"]).decode()
    return [line[3:] for line in status.splitlines()]


def main():
    if len(sys.argv) < 2:
        print("Usage: ./release.py 'commit message'")
        sys.exit(1)

    message = sys.argv[1]
    changes = get_git_changes()

    if not changes:
        print("No changes detected in git.")
        return

    for cfg in CONFIGS:
        cfg_path = Path(cfg)
        if not cfg_path.exists():
            continue

        # Check if this specific folder has changes
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

        # 2. Map ALL current files (to support deletions)
        # We ignore .version and .manifest.json themselves
        all_files = [
            str(p)
            for p in cfg_path.rglob("*")
            if p.is_file() and p.name not in [".version", ".manifest.json"]
        ]

        # 3. Write Manifest
        manifest = {"version": version, "message": message, "files": all_files}

        (cfg_path / ".manifest.json").write_text(json.dumps(manifest, indent=2))
        ver_file.write_text(json.dumps({"version": version}))
        print(f"[+] {cfg}: Bumped to v{version}")

    # Git ops
    subprocess.run(["git", "add", "."])
    subprocess.run(["git", "commit", "-m", f"release: {message}"])
    subprocess.run(["git", "push"])
    print("\n✅ Pushed to GitHub.")


if __name__ == "__main__":
    main()
