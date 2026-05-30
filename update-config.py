#!/usr/bin/env python3

import json
import urllib.request
import urllib.error
from pathlib import Path
import sys

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
CONFIG_DIR = Path.home() / ".config"
CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def fetch_json(url: str):
    with urllib.request.urlopen(url, timeout=10) as r:
        return json.loads(r.read().decode())


def fetch_text(url: str):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read().decode()


def yesno(prompt: str) -> str:
    while True:
        ans = input(prompt + " [y/n/a/q]: ").strip().lower()
        if ans in ("y", "n", "a", "q"):
            return ans


def main():
    # Check for interactive terminal
    if not sys.stdin.isatty():
        print("❌ Error: This script requires an interactive terminal.")
        print("💡 In fish, run:")
        print("   python3 (curl -fsSL .../update-config.py | psub)")
        print("   # or download first:")
        print("   curl -fsSL .../update-config.py -o update.py && python3 update.py")
        return

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

        manifest_url = f"{REPO_RAW}/{cfg}/.manifest.json"
        try:
            manifest = fetch_json(manifest_url)
        except urllib.error.HTTPError as e:
            print(f"⚠️  {cfg}: Manifest not found ({e.code}) at {manifest_url}")
            continue
        except Exception as e:
            print(f"⚠️  {cfg}: Could not fetch manifest: {e}")
            continue

        remote_version = manifest["version"]
        if remote_version <= local_version:
            print(f"✓ {cfg} is up to date (v{local_version})")
            continue

        print(f"\n📦 {cfg} update available")
        print(f"   Local:  v{local_version} → Remote: v{remote_version}")
        if msg := manifest.get("message"):
            print(f"   📝 {msg}")
        print("\n   Files to update:")
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

            print(f"\n   ↓ Fetching: {url}")

            # Step 1: Download
            try:
                content = fetch_text(url)
                print(f"   ✓ Downloaded ({len(content)} bytes)")
            except urllib.error.HTTPError as e:
                print(f"   ✗ Download failed: HTTP {e.code}")
                print("      The file may not exist at that path in the repo.")
                print(
                    "      Check your manifest 'files' paths are relative (e.g., 'modules/foo.lua', not 'hypr/modules/foo.lua')"
                )
                continue
            except urllib.error.URLError as e:
                print(f"   ✗ Download failed: Network error — {e.reason}")
                continue
            except Exception as e:
                print(f"   ✗ Download failed: {type(e).__name__}: {e}")
                continue

            # Step 2: Write to disk
            try:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(content)
                print(f"   ✓ Installed → {target}")
            except PermissionError:
                print(f"   ✗ Write failed: Permission denied for {target}")
                print(f"      Try: chmod -R u+w ~/.config/{cfg}")
                continue
            except Exception as e:
                print(f"   ✗ Write failed: {type(e).__name__}: {e}")
                continue

        # Update local version tracker
        try:
            local_version_file.parent.mkdir(parents=True, exist_ok=True)
            local_version_file.write_text(
                json.dumps({"version": remote_version}, indent=2) + "\n"
            )
            print(f"\n✅ {cfg} updated to v{remote_version}")
        except Exception as e:
            print(f"\n⚠️  Could not update version file for {cfg}: {e}")

    print("\n🎉 Update complete!")


if __name__ == "__main__":
    main()
