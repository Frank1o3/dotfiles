#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path
import sys
import configparser

ROOT = Path(".").resolve()


# =========================================================
# Config Detection
# =========================================================
def find_configs():
    configs = []

    for marker in Path(".").rglob(".config-root"):
        if marker.parent.parent.resolve() == ROOT:
            configs.append(marker.parent.name)
        else:
            print(f"⚠️ Ignoring misplaced .config-root in {marker}")

    return sorted(set(configs))


def load_config_meta(cfg_path: Path):
    parser = configparser.ConfigParser()
    parser.read(cfg_path / ".config-root")

    return {
        "install_path": parser.get("DEFAULT", "install_path", fallback=None),
        "protected": [
            x.strip()
            for x in parser.get("DEFAULT", "protected", fallback="").split(",")
            if x.strip()
        ],
        "optional": parser.getboolean("DEFAULT", "optional", fallback=False),
    }


CONFIGS = find_configs()


# =========================================================
# Git Helpers
# =========================================================
def get_git_changes():
    status = subprocess.check_output(["git", "status", "--porcelain"]).decode()
    return [line[3:].strip() for line in status.splitlines()]


# =========================================================
# Core Logic
# =========================================================
def main():
    if len(sys.argv) < 2:
        print("Usage: ./release.py 'commit message'")
        sys.exit(1)

    message = sys.argv[1]
    changes = get_git_changes()

    if not changes:
        print("No changes detected.")
        return

    repo_manifest = {"configs": {}}
    any_updates = False

    for cfg in CONFIGS:
        cfg_path = Path(cfg)

        has_changes = any(path.startswith(cfg + "/") for path in changes)

        if not has_changes:
            print(f"[-] {cfg}: no changes")
            continue

        meta = load_config_meta(cfg_path)

        # version
        ver_file = cfg_path / ".version"
        version = 1
        if ver_file.exists():
            try:
                version = json.loads(ver_file.read_text())["version"] + 1
            except:
                pass

        # file list (FULL PATHS)
        files = [
            str(p.resolve().relative_to(ROOT))
            for p in cfg_path.rglob("*")
            if p.is_file()
            and p.name not in [".version", ".manifest.json", ".config-root"]
        ]

        if not files and any(cfg_path.iterdir()):
            print(f"⚠️ {cfg}: empty manifest, skipping")
            continue

        manifest = {
            "version": version,
            "message": message,
            "files": files,
        }

        # write per-config
        (cfg_path / ".manifest.json").write_text(json.dumps(manifest, indent=2))
        ver_file.write_text(json.dumps({"version": version}, indent=2))

        # add to global manifest
        repo_manifest["configs"][cfg] = {
            "version": version,
            "install_path": meta["install_path"],
            "protected": meta["protected"],
            "optional": meta["optional"],
        }

        print(f"[+] {cfg}: v{version} ({len(files)} files)")
        any_updates = True

    # write global manifest
    Path(".repo-manifest.json").write_text(json.dumps(repo_manifest, indent=2))

    if any_updates:
        subprocess.run(["git", "add", "."])
        subprocess.run(["git", "commit", "-m", f"release: {message}"])
        subprocess.run(["git", "push"])
        print("\n✅ Released + pushed")
    else:
        print("\nℹ️ Nothing updated")


if __name__ == "__main__":
    main()