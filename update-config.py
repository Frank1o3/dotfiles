#!/usr/bin/env python3

import json
import urllib.request
from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/Frank1o3/dotfiles/main"
TTY = open("/dev/tty", "r")


# =========================================================
# Networking
# =========================================================
def fetch(url):
    with urllib.request.urlopen(url, timeout=10) as r:
        return r.read()


# =========================================================
# Prompt
# =========================================================
def yesno(prompt: str) -> bool:
    while True:
        print(f"{prompt} [Y/n]: ", end="", flush=True)
        ans = TTY.readline().strip().lower() or "y"

        if ans in ("y", "yes"):
            return True
        if ans in ("n", "no"):
            return False


# =========================================================
# Placeholder Replacement
# =========================================================
def replace_placeholders(file: Path):
    try:
        content = file.read_text()
    except:
        return  # skip binary files

    home = str(Path.home())

    if "{HOME}" in content:
        file.write_text(content.replace("{HOME}", home))


def replace_all(dest: Path):
    for f in dest.rglob("*"):
        if f.is_file():
            replace_placeholders(f)


# =========================================================
# Cleanup (rsync-like delete)
# =========================================================
def cleanup_removed_files(install_path: Path, expected_files: set):
    for existing in install_path.rglob("*"):
        if not existing.is_file():
            continue

        rel = str(existing.relative_to(install_path))

        if rel not in expected_files and not rel.startswith(".version"):
            print(f"🧹 Removing old file: {rel}")
            existing.unlink()


# =========================================================
# Main
# =========================================================
def main():
    print("🚀 Smart Update\n")

    repo_manifest = json.loads(fetch(f"{REPO_RAW}/.repo-manifest.json"))

    for cfg, meta in repo_manifest["configs"].items():
        if meta.get("optional"):
            if not yesno(f"Install optional config {cfg}?"):
                continue

        install_path = (
            Path(meta["install_path"]).expanduser()
            if meta["install_path"]
            else Path.home() / ".config" / cfg
        )

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

        expected_files = set()

        for f in manifest["files"]:
            rel = Path(f)

            # 🔒 SAFETY: ensure path starts with cfg
            if not str(rel).startswith(cfg):
                print(f"⚠️ Skipping invalid path: {rel}")
                continue

            subpath = rel.relative_to(cfg)
            target = install_path / subpath

            expected_files.add(str(subpath))

            if str(subpath) in meta.get("protected", []) and target.exists():
                print(f"🔒 Skipping protected: {rel}")
                continue

            if target.exists():
                if not yesno(f"Update {rel}?"):
                    continue

            try:
                content = fetch(f"{REPO_RAW}/{f}")
                target.parent.mkdir(parents=True, exist_ok=True)

                # Write file
                try:
                    target.write_text(content.decode())
                except:
                    target.write_bytes(content)

                print(f"✔ {rel}")

            except Exception as e:
                print(f"❌ {rel}: {e}")

        # 🧹 Cleanup removed files
        cleanup_removed_files(install_path, expected_files)

        # 🔁 Replace ALL placeholders (like rsync script)
        replace_all(install_path)

        # Write version
        install_path.mkdir(parents=True, exist_ok=True)
        (install_path / ".version").write_text(json.dumps({"version": remote_ver}))

        print(f"✨ {cfg} updated\n")


if __name__ == "__main__":
    main()
