#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path
import configparser

ROOT = Path(__file__).resolve().parent
CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))

VERBOSE = os.environ.get("VERBOSE", "0") == "1"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"


# =========================================================
# Detection
# =========================================================
def find_configs():
    configs = []

    for marker in ROOT.rglob(".config-root"):
        # Only allow one level deep (./cfg/.config-root)
        if marker.parent.parent.resolve() == ROOT.resolve():
            configs.append(marker.parent.name)

    return sorted(set(configs))


def load_meta(cfg):
    parser = configparser.ConfigParser()
    parser.read(ROOT / cfg / ".config-root")

    return {
        "install_path": parser.get("DEFAULT", "install_path", fallback=None)
    }


CONFIGS = find_configs()


# =========================================================
# Helpers
# =========================================================
def log(msg):
    print(f"ℹ️  {msg}")


def run(cmd):
    if DRY_RUN:
        print("[dry-run]", " ".join(cmd))
        return

    if VERBOSE:
        log("Running: " + " ".join(cmd))

    subprocess.run(cmd, check=True)


def replace_home_placeholders(dest: Path):
    home = str(Path.home())

    for file in dest.rglob("*"):
        if not file.is_file():
            continue

        try:
            content = file.read_text()

            if "{HOME}" not in content:
                continue

            new_content = content.replace("{HOME}", home)

            # Only write if changed
            if new_content != content:
                file.write_text(new_content)

                if VERBOSE:
                    log(f"Replaced {{HOME}} in {file}")

        except Exception as e:
            if VERBOSE:
                log(f"Skipped {file}: {e}")


# =========================================================
# Sync
# =========================================================
def sync(cfg):
    src = ROOT / cfg
    meta = load_meta(cfg)

    dest = Path(meta["install_path"]).expanduser() if meta["install_path"] else CONFIG_HOME / cfg

    dest.mkdir(parents=True, exist_ok=True)

    log(f"{cfg} → {dest}")

    cmd = [
        "rsync",
        "-a",
        "--delete",
        "--checksum",
        "--exclude=.git",
        "--exclude=.config-root",
        "--exclude=colors.css",
        "--exclude=colors.lua",
        "--exclude=colors.conf",
        "--exclude=*.cache",
    ]

    if VERBOSE:
        cmd.append("--itemize-changes")

    cmd += [f"{src}/", f"{dest}/"]

    run(cmd)

    # Replace placeholders AFTER sync
    replace_home_placeholders(dest)


# =========================================================
# Main
# =========================================================
def main():
    if not CONFIGS:
        log("No configs found.")
        return

    if VERBOSE:
        log(f"Detected configs: {CONFIGS}")

    for cfg in CONFIGS:
        try:
            sync(cfg)
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed syncing {cfg}: {e}")


if __name__ == "__main__":
    main()