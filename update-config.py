#!/usr/bin/env python3
import json
import urllib.request
from pathlib import Path
import sys

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
CONFIG_DIR = Path.home() / ".config"
CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read()


def yesno(prompt: str) -> bool:
    # Returns True for 'yes', False for 'no'
    while True:
        ans = input(f"{prompt} [y/n]: ").strip().lower()
        if ans in ("y", "n"):
            return ans == "y"


def main():
    print("🚀 Starting Update Check...\n")

    for cfg in CONFIGS:
        local_dir = CONFIG_DIR / cfg
        local_version_file = local_dir / ".version"

        local_ver = 0
        if local_version_file.exists():
            try:
                local_ver = json.loads(local_version_file.read_text())["version"]
            except:
                pass

        try:
            manifest_content = fetch(f"{REPO_RAW}/{cfg}/.manifest.json").decode()
            manifest = json.loads(manifest_content)
        except:
            print(f"⚠️  {cfg}: Could not fetch manifest.")
            continue

        remote_ver = manifest["version"]

        if remote_ver <= local_ver:
            print(f"✅ {cfg} is up to date (v{local_ver})")
            continue

        print(f"\n📦 {cfg} Update Available: v{local_ver} -> v{remote_ver}")
        remote_files = manifest["files"]

        # 1. ASK BEFORE DELETING
        for item in local_dir.rglob("*"):
            if item.is_file() and item.name not in [".version", ".manifest.json"]:
                rel_path = str(item.relative_to(CONFIG_DIR))
                if rel_path not in remote_files:
                    if yesno(f"   🗑️  {rel_path} is not in repo. Delete it?"):
                        item.unlink()
                    else:
                        print(f"   skipping deletion of {rel_path}")

        # 2. ASK BEFORE OVERWRITING
        for f in remote_files:
            target = CONFIG_DIR / f

            # If file exists, ask before overwriting
            if target.exists():
                if not yesno(f"   ↓ Update {f}?"):
                    print(f"   skipping {f}")
                    continue

            print(f"   📥 Downloading: {f}")
            try:
                content = fetch(f"{REPO_RAW}/{f}")
                target.parent.mkdir(parents=True, exist_ok=True)

                if target.suffix in [".conf", ".lua", ".json", ".sh", ".css", ".ini"]:
                    text = content.decode().replace("{HOME}", str(Path.home()))
                    target.write_text(text)
                else:
                    target.write_bytes(content)
            except Exception as e:
                print(f"   ❌ Failed {f}: {e}")

        # Update version file
        local_version_file.parent.mkdir(parents=True, exist_ok=True)
        local_version_file.write_text(json.dumps({"version": remote_ver}))
        print(f"✨ {cfg} update process finished.\n")


if __name__ == "__main__":
    main()
