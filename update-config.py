#!/usr/bin/env python3

import json
import urllib.request
from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"


def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read()


def yesno(prompt):
    ans = input(f"{prompt} [Y/n]: ").strip().lower()
    return ans in ("", "y", "yes")


def main():
    print("🚀 Smart Update\n")

    repo_manifest = json.loads(fetch(f"{REPO_RAW}/.repo-manifest.json"))

    for cfg, meta in repo_manifest["configs"].items():

        if meta.get("optional"):
            if not yesno(f"Install optional config {cfg}?"):
                continue

        install_path = Path(meta["install_path"]).expanduser() if meta["install_path"] else Path.home() / ".config" / cfg

        version_file = install_path / ".version"

        local_ver = 0
        if version_file.exists():
            try:
                local_ver = json.loads(version_file.read_text())["version"]
            except:
                pass

        try:
            manifest = json.loads(fetch(f"{REPO_RAW}/{cfg}/.manifest.json"))
        except:
            print(f"⚠️ {cfg}: no manifest")
            continue

        remote_ver = manifest["version"]

        if remote_ver <= local_ver:
            print(f"✅ {cfg} up to date")
            continue

        print(f"📦 {cfg}: v{local_ver} → v{remote_ver}")

        for f in manifest["files"]:
            rel = Path(f)
            target = Path.home() / ".config" / rel.relative_to(cfg)

            if str(rel.relative_to(cfg)) in meta["protected"] and target.exists():
                print(f"🔒 Skipping protected: {rel}")
                continue

            if target.exists():
                if not yesno(f"Update {rel}?"):
                    continue

            try:
                content = fetch(f"{REPO_RAW}/{f}")
                target.parent.mkdir(parents=True, exist_ok=True)

                try:
                    target.write_text(content.decode())
                except:
                    target.write_bytes(content)

                print(f"✔ {rel}")

            except Exception as e:
                print(f"❌ {rel}: {e}")

        install_path.mkdir(parents=True, exist_ok=True)
        (install_path / ".version").write_text(json.dumps({"version": remote_ver}))

        print(f"✨ {cfg} updated\n")


if __name__ == "__main__":
    main()