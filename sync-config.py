#!/usr/bin/env python3
"""
Dotfiles Sync Script
Syncs local repo configs -> ~/.config
Replaces {HOME} placeholders with actual $HOME path
"""
import os
import sys
import shutil
import subprocess
from pathlib import Path

# =========================================================
# Configuration & Environment
# =========================================================
VERBOSE = os.environ.get("VERBOSE", "0") == "1"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"
REPO_DIR = Path(__file__).resolve().parent
CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
WALLPAPER_HOME = Path.home() / "wallpapers"

CONFIGS = ["hypr", "waybar", "kitty", "dunst", "fuzzel", "wallust"]
TEXT_EXTENSIONS = {
    ".conf", ".cfg", ".ini", ".lua", ".sh", ".bash", ".toml",
    ".json", ".yaml", ".yml", ".css", ".scss", ".py", ".txt",
    ".md", ".js", ".ts", ".html", ".xml", ".rc", ".theme"
}

# =========================================================
# Logging Helpers
# =========================================================
def log(msg): print(f"ℹ️  {msg}")
def warn(msg): print(f"⚠️  {msg}", file=sys.stderr)
def success(msg): print(f"✅ {msg}")

def run_cmd(cmd, **kwargs):
    """Execute command, respecting DRY_RUN and VERBOSE."""
    cmd_str = " ".join(str(c) for c in cmd)
    if DRY_RUN:
        print(f"[dry-run] {cmd_str}")
        return 0
    if VERBOSE:
        log(f"Running: {cmd_str}")
    try:
        return subprocess.run(cmd, **kwargs).returncode
    except FileNotFoundError:
        warn(f"Command not found: {cmd[0]}")
        return 1

# =========================================================
# Core Functions
# =========================================================
def sync_config(name: str):
    src = REPO_DIR / name
    dest = CONFIG_HOME / name

    if not src.is_dir():
        warn(f"Missing repo config: {name}")
        return

    dest.mkdir(parents=True, exist_ok=True)

    # Skip diff if destination is empty/new
    if dest.exists() and any(dest.iterdir()):
        try:
            subprocess.run(
                ["diff", "-qr", str(src), str(dest)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True
            )
            if VERBOSE: log(f"No changes: {name}")
            return
        except subprocess.CalledProcessError:
            pass  # Files differ

    log(f"Syncing: {name}")
    run_cmd(["rsync", "-a", "--delete", "--exclude=.git", f"{src}/", f"{dest}/"])
    success(f"Updated: {name}")

def replace_home_placeholder(target_dir: Path):
    home_str = str(Path.home())
    if VERBOSE: log(f"Scanning for {{HOME}} in: {target_dir}")

    for file in target_dir.rglob("*"):
        if not file.is_file() or file.is_symlink():
            continue
        if file.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        try:
            content = file.read_text(encoding="utf-8", errors="ignore")
            if "{HOME}" in content:
                if DRY_RUN:
                    log(f"[dry-run] Would replace {{HOME}} in: {file}")
                else:
                    file.write_text(content.replace("{HOME}", home_str), encoding="utf-8")
                    if VERBOSE: log(f"✓ Replaced {{HOME}} in: {file}")
        except Exception as e:
            warn(f"Failed to process {file}: {e}")

def sync_wallpapers():
    src = REPO_DIR / "wallpapers"
    if not src.is_dir():
        return

    WALLPAPER_HOME.mkdir(parents=True, exist_ok=True)
    log("Syncing wallpapers...")

    if WALLPAPER_HOME.exists() and any(WALLPAPER_HOME.iterdir()):
        try:
            subprocess.run(
                ["diff", "-qr", str(src), str(WALLPAPER_HOME)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True
            )
            if VERBOSE: log("No changes: wallpapers")
            return
        except subprocess.CalledProcessError:
            pass

    run_cmd(["rsync", "-a", "--delete", "--exclude=.git", f"{src}/", f"{WALLPAPER_HOME}/"])
    success("Updated wallpapers")

def restart_service(name: str):
    if not shutil.which(name):
        return
    try:
        res = subprocess.run(["pgrep", "-x", name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode == 0:
            log(f"Restarting {name}...")
            subprocess.run(["pkill", "-x", name], check=False)
            # Detach from terminal (equivalent to `nohup cmd &`)
            subprocess.Popen(
                [name],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True
            )
    except Exception as e:
        warn(f"Failed to restart {name}: {e}")

def reload_services():
    if shutil.which("hyprctl"):
        log("Reloading Hyprland...")
        run_cmd(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    restart_service("waybar")
    restart_service("dunst")

# =========================================================
# Main Execution
# =========================================================
def main():
    log("Starting config sync...")
    for config in CONFIGS:
        sync_config(config)

    sync_wallpapers()

    log("🔧 Resolving {HOME} placeholders...")
    for config in CONFIGS:
        dest = CONFIG_HOME / config
        if dest.is_dir():
            replace_home_placeholder(dest)
    if WALLPAPER_HOME.is_dir():
        replace_home_placeholder(WALLPAPER_HOME)

    reload_services()
    success("Config sync complete")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        warn("Interrupted by user")
        sys.exit(1)
    except Exception as e:
        warn(f"Unexpected error: {e}")
        sys.exit(1)