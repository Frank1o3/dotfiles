#!/usr/bin/env python3

import json
import urllib.request
import tempfile
from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
CONFIG_DIR = Path.home() / ".config"
CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def fetch_json(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return json.loads(r.read().decode())


def fetch_text(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read().decode()


def yesno(prompt):
    while True:
        ans = input(prompt + " [y/n/a/q]: ").strip().lower()
        if ans in ("y", "n", "a", "q"):
            return ans


def main():
    print("🔍 Checking updates...\n")
    all_mode = False

    for cfg in CONFIGS:
        local_version_file = CONFIG_DIR / cfg / ".version"
        local_version = 0

        if local_version_file.exists():
            try:
                local_version = json.loads(local_version_file.read_text())["version"]
            except Exception:
                pass

        try:
            manifest = fetch_json(f"{REPO_RAW}/{cfg}/.manifest.json")
        except Exception as e:
            print(f"⚠️  Could not fetch manifest for {cfg}: {e}")
            continue

        remote_version = manifest["version"]
        if remote_version <= local_version:
            print(f"✓ {cfg} is up to date (v{local_version})")
            continue

        print(f"\n📦 {cfg} update available")
        print(f"   Local:  v{local_version} → Remote: v{remote_version}")
        if msg := manifest.get("message"):
            print(f"   📝 {msg}")
        print(f"\n   Files to update:")
        for f in manifest["files"]:
            print(f"    - {f}")

        for f in manifest["files"]:
            if not all_mode:
                choice = yesno(f"\n   Update {cfg}/{f}?")
                if choice == "q":
                    print("\n👋 Quitting.")
                    return
                if choice == "a":
                    all_mode = True
                    print("   → Applying to all remaining files")
                if choice == "n":
                    continue

            url = f"{REPO_RAW}/{cfg}/{f}"
            target = CONFIG_DIR / cfg / f

            try:
                print(f"   ↓ Downloading {f}...")
                content = fetch_text(url)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(content)
                print(f"   ✓ Installed {f}")
            except Exception as e:
                print(f"   ✗ Failed to download {f}: {e}")

        # Update local version tracker
        local_version_file.parent.mkdir(parents=True, exist_ok=True)
        local_version_file.write_text(
            json.dumps({"version": remote_version}, indent=2) + "\n"
        )
        print(f"\n✅ {cfg} updated to v{remote_version}")

    print("\n🎉 Update complete!")


if __name__ == "__main__":
    main()
