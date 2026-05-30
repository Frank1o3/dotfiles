#!/usr/bin/env python3
import json
import urllib.request
from pathlib import Path
import os

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
CONFIG_DIR = Path.home() / ".config"
CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read()


def main():
    print("🚀 Starting Update Check...\n")

    for cfg in CONFIGS:
        local_dir = CONFIG_DIR / cfg
        local_version_file = local_dir / ".version"

        # Get local version
        local_ver = 0
        if local_version_file.exists():
            try:
                local_ver = json.loads(local_version_file.read_text())["version"]
            except:
                pass

        # Get remote manifest
        try:
            manifest = json.loads(fetch(f"{REPO_RAW}/{cfg}/.manifest.json").decode())
        except:
            print(f"⚠️  {cfg}: Could not fetch manifest.")
            continue

        remote_ver = manifest["version"]

        if remote_ver <= local_ver:
            print(f"✅ {cfg} is up to date (v{local_ver})")
            continue

        print(f"📦 Updating {cfg}: v{local_ver} -> v{remote_ver}")
        remote_files = manifest["files"]  # List of relative paths like "hypr/init.lua"

        # 1. DELETE files that no longer exist in the repo
        # Walk local directory
        for item in local_dir.rglob("*"):
            if item.is_file() and item.name not in [".version"]:
                # Convert local path to relative repo path format
                rel_path = str(item.relative_to(CONFIG_DIR))
                if rel_path not in remote_files:
                    print(f"   🗑️  Removing deprecated: {rel_path}")
                    item.unlink()

        # 2. DOWNLOAD/UPDATE files
        for f in remote_files:
            target = CONFIG_DIR / f
            print(f"   ↓ Downloading: {f}")
            try:
                content = fetch(f"{REPO_RAW}/{f}")
                target.parent.mkdir(parents=True, exist_ok=True)

                # Check if we should replace {HOME}
                if target.suffix in [".conf", ".lua", ".json", ".sh"]:
                    text = content.decode().replace("{HOME}", str(Path.home()))
                    target.write_text(text)
                else:
                    target.write_bytes(content)
            except Exception as e:
                print(f"   ❌ Failed {f}: {e}")

        # Update version file
        local_version_file.parent.mkdir(parents=True, exist_ok=True)
        local_version_file.write_text(json.dumps({"version": remote_ver}))
        print(f"✨ {cfg} update complete.\n")


if __name__ == "__main__":
    main()
