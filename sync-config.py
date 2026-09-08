#!/usr/bin/env python3

import configparser
import os
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))

VERBOSE = os.environ.get("VERBOSE", "0") == "1"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"
AUTO = os.environ.get("AUTO", "0") == "1"  # accept every change without prompting

EXCLUDES = [
    "--exclude=.git",
    "--exclude=.config-root",
    "--exclude=colors.css",
    "--exclude=colors.lua",
    "--exclude=colors.conf",
    "--exclude=colors.json",
    "--exclude=*.cache",
]

try:
    TTY = open("/dev/tty", "r")
except OSError:
    TTY = None


# =========================================================
# Detection — unchanged: `.config-root` is still the only
# thing that determines what gets synced. No manifest here.
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
    protected_raw = parser.get("DEFAULT", "protected", fallback="")
    return {
        "install_path": parser.get("DEFAULT", "install_path", fallback=None),
        "protected": {p.strip() for p in protected_raw.split(",") if p.strip()},
    }


CONFIGS = find_configs()


# =========================================================
# Helpers
# =========================================================
def log(msg):
    print(f"  {msg}")


def yesno(prompt: str, default: bool) -> bool:
    if AUTO:
        return default

    hint = "[Y/n]" if default else "[y/N]"

    if TTY is None:
        log(f"{prompt} {hint}: no tty, defaulting to {'yes' if default else 'no'}")
        return default

    while True:
        print(f"  {prompt} {hint}: ", end="", flush=True)
        ans = TTY.readline().strip().lower()
        if ans == "":
            return default
        if ans in ("y", "yes"):
            return True
        if ans in ("n", "no"):
            return False


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
            if new_content != content:
                file.write_text(new_content)
                if VERBOSE:
                    log(f"Replaced {{HOME}} in {file}")
        except Exception as e:
            if VERBOSE:
                log(f"Skipped {file}: {e}")


# =========================================================
# Diffing — checksum comparison via rsync dry-run, no
# manifest or .version involved. If the local file's
# checksum differs from the repo's, it's a candidate.
# =========================================================
ITEMIZE_RE = re.compile(r"^(\S+)\s+(.*)$")


def plan_changes(src: Path, dst: Path):
    """Returns [(kind, rel_path), ...] where kind is 'update' or 'delete'."""
    cmd = [
        "rsync", "-rlptD", "--checksum", "--delete", "-ni",
        *EXCLUDES,
        f"{src}/", f"{dst}/",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)

    changes = []
    for line in result.stdout.splitlines():
        m = ITEMIZE_RE.match(line)
        if not m:
            continue
        code, relpath = m.groups()
        relpath = relpath.rstrip("/")

        if code == "*deleting":
            changes.append(("delete", relpath))
        elif code.startswith(">f"):
            changes.append(("update", relpath))
        # directory-only itemize lines (cd+++++++++) are skipped —
        # mkdir happens implicitly when a contained file is copied.

    return changes


# =========================================================
# Sync
# =========================================================
def sync(cfg):
    src = ROOT / cfg
    meta = load_meta(cfg)
    protected = meta["protected"]

    dest = Path(meta["install_path"]).expanduser() if meta["install_path"] else CONFIG_HOME / cfg
    dest.mkdir(parents=True, exist_ok=True)

    log(f"{cfg} → {dest}")

    changes = plan_changes(src, dest)
    if not changes:
        log("up to date")
        return

    touched = False
    for kind, relpath in changes:
        name = Path(relpath).name

        if name in protected:
            if VERBOSE:
                log(f"Skipping protected file: {relpath}")
            continue

        src_file = src / relpath
        dst_file = dest / relpath

        if kind == "delete":
            if not yesno(f"Delete {cfg}/{relpath} (removed upstream)?", default=False):
                continue
            if DRY_RUN:
                print("[dry-run] rm", dst_file)
                continue
            dst_file.unlink(missing_ok=True)
            log(f"removed {relpath}")
        else:
            if not yesno(f"Update {cfg}/{relpath}?", default=True):
                continue
            if DRY_RUN:
                print("[dry-run] cp", src_file, "->", dst_file)
                continue
            dst_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_file, dst_file)
            log(f"updated {relpath}")

        touched = True

    if touched and not DRY_RUN:
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
            print(f"Failed syncing {cfg}: {e}")


if __name__ == "__main__":
    main()