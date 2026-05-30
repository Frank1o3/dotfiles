#!/usr/bin/env python3

import json
import shutil
import tempfile
import urllib.request
from pathlib import Path

REPO_RAW = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main"

CONFIG_DIR = Path.home() / ".config"

CONFIGS = ["hypr", "waybar", "kitty", "fuzzel", "wallust", "swaync"]


def fetch_json(url):
    with urllib.request.urlopen(url) as r:
        return json.loads(r.read().decode())


def fetch_text(url):
    with urllib.request.urlopen(url) as r:
        return r.read().decode()


def yesno(prompt):
    while True:
        ans = input(prompt + " [y/n/a/q]: ").strip().lower()
        if ans in ("y", "n", "a", "q"):
            return ans


def main():
    print("Checking updates...\n")

    tmp = Path(tempfile.mkdtemp())

    all_mode = False

    for cfg in CONFIGS:
        local_version_file = CONFIG_DIR / cfg / ".version"
        local_version = 0

        if local_version_file.exists():
            try:
                local_version = json.loads(local_version_file.read_text())["version"]
            except:
                pass

        try:
            manifest = fetch_json(f"{REPO_RAW}/{cfg}/.manifest.json")
        except Exception:
            continue

        remote_version = manifest["version"]

        if remote_version <= local_version:
            continue

        print(f"\n== {cfg} ==")
        print(f"Local:  {local_version}")
        print(f"Remote: {remote_version}")
        print(f"Message: {manifest.get('message', '')}")
        print("\nFiles:")

        for f in manifest["files"]:
            print(" -", f)

        for f in manifest["files"]:
            if not all_mode:
                choice = yesno(f"Update {cfg}/{f}?")
                if choice == "q":
                    print("Quit")
                    return
                if choice == "a":
                    all_mode = True
                if choice == "n":
                    continue

            url = f"{REPO_RAW}/{cfg}/{f}"
            target = CONFIG_DIR / cfg / f

            print(f"Downloading {f}")

            target.parent.mkdir(parents=True, exist_ok=True)

            content = fetch_text(url)
            target.write_text(content)

        # update version locally
        (CONFIG_DIR / cfg / ".version").write_text(
            json.dumps({"version": remote_version}, indent=2)
        )

    print("\nUpdate complete")


if __name__ == "__main__":
    main()
