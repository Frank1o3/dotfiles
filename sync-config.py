#!/usr/bin/env python3

import os
import sys
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
    subprocess.run(cmd)


# =========================================================
# Sync
# =========================================================
def sync(cfg):
    src = ROOT / cfg
    meta = load_meta(cfg)

    dest = Path(meta["install_path"]).expanduser() if meta["install_path"] else CONFIG_HOME / cfg

    dest.mkdir(parents=True, exist_ok=True)

    log(f"{cfg} → {dest}")

    run([
        "rsync",
        "-a",
        "--exclude=.git",
        "--exclude=.config-root",
        f"{src}/",
        f"{dest}/"
    ])


def main():
    for cfg in CONFIGS:
        sync(cfg)


if __name__ == "__main__":
    main()