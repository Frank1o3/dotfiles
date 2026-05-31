#!/usr/bin/env python3
import json
import urllib.request
from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
CONFIG_DIR = Path.home() / ".config"
CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync", "fish"]


def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read()


def yesno(prompt: str) -> bool:
    while True:
        ans = input(f"{prompt} [Y/n]: ").strip().lower() or "y"
        if ans in ("y", "n"):
            return ans == "y"


def main():
    print("🚀 Starting Smart Sync...\n")

    for cfg in CONFIGS:
        local_dir = CONFIG_DIR / cfg
        local_version_file = local_dir / ".version"

        # 1. Get Versions
        local_ver = 0
        if local_version_file.exists():
            try:
                local_ver = json.loads(local_version_file.read_text())["version"]
            except:
                pass

        try:
            manifest = json.loads(fetch(f"{REPO_RAW}/{cfg}/.manifest.json").decode())
        except:
            print(f"⚠️  {cfg}: Could not fetch manifest. Skipping.")
            continue

        remote_ver = manifest["version"]
        remote_files = manifest["files"]

        # If versions match, we can still check for missing files,
        # but we skip the heavy lifting.
        if remote_ver <= local_ver:
            print(f"✅ {cfg} is already v{local_ver}. Checking for orphan files...")
        else:
            print(f"📦 {cfg} Update Available: v{local_ver} -> v{remote_ver}")

        # --- PHASE 1: ORPHAN CHECK (Local but not in Repo) ---
        if local_dir.exists():
            for item in local_dir.rglob("*"):
                if item.is_file() and item.name not in [".version", ".manifest.json"]:
                    # Convert to repo-style path: "hypr/init.lua"
                    rel_path = str(item.relative_to(CONFIG_DIR))

                    if rel_path not in remote_files:
                        if not yesno(f"   ❓ {rel_path} is local-only. Keep it?"):
                            print(f"   🗑️  Deleting {rel_path}...")
                            item.unlink()
                        else:
                            print(f"   💾 Keeping local {rel_path}")

        # --- PHASE 2: SMART DOWNLOAD (Missing or Outdated) ---
        # We only ask for updates if the remote version is higher
        for f in remote_files:
            target = CONFIG_DIR / f

            # Case A: File is missing locally
            if not target.exists():
                print(f"   📥 Found new file: {f}")
                download = True

            # Case B: Version mismatch (Update available)
            elif remote_ver > local_ver:
                if yesno(f"   🔄 Update existing {f}?"):
                    download = True
                else:
                    print(f"   ⏭️  Skipping {f} (keeping your local changes)")
                    download = False
            else:
                download = False

            if download:
                try:
                    content = fetch(f"{REPO_RAW}/{f}")
                    target.parent.mkdir(parents=True, exist_ok=True)

                    if target.suffix in [
                        ".conf",
                        ".lua",
                        ".json",
                        ".sh",
                        ".css",
                        ".ini",
                    ]:
                        text = content.decode().replace("{HOME}", str(Path.home()))
                        target.write_text(text)
                    else:
                        target.write_bytes(content)
                    print(f"   ✅ Installed {f}")
                except Exception as e:
                    print(f"   ❌ Failed {f}: {e}")

        # 3. Finalize Version
        local_version_file.parent.mkdir(parents=True, exist_ok=True)
        local_version_file.write_text(json.dumps({"version": remote_ver}))
        print(f"✨ {cfg} sync complete.\n")


if __name__ == "__main__":
    main()
