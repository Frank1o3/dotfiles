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
    subprocess.run(cmd, check=True)


def replace_home_placeholders(dest: Path):
    home = str(Path.home())

    for file in dest.rglob("*"):
        if not file.is_file():
            continue

        try:
            content = file.read_text()

            if "{HOME}" in content:
                new_content = content.replace("{HOME}", home)
                file.write_text(new_content)

                if VERBOSE:
                    log(f"Replaced {{HOME}} in {file}")

        except Exception:
            # Skip binary or unreadable files
            continue


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

    # 🔥 NEW STEP: Replace {HOME} placeholders
    replace_home_placeholders(dest)


def main():
    for cfg in CONFIGS:
        sync(cfg)


if __name__ == "__main__":
    main()