#!/usr/bin/env python3
"""
Dotfiles Installer
Clones repo, backs up old configs, deploys new ones, replaces {HOME} placeholders
"""
import os
import sys
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path

# =========================================================
# Configuration & Environment
# =========================================================
REPO_URL = sys.argv[1] if len(sys.argv) > 1 else "https://github.com/Frank1o3/dotfiles.git"
REPO_BRANCH = sys.argv[2] if len(sys.argv) > 2 else "main"

VERBOSE = os.environ.get("VERBOSE", "0") == "1"
SKIP_DEPS = os.environ.get("SKIP_DEPS", "0") == "1"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"

CONFIG_DIRS = ["swaync", "fuzzel", "hypr", "kitty", "wallust", "waybar"]
TEXT_EXTENSIONS = {
    ".conf", ".cfg", ".ini", ".lua", ".sh", ".bash", ".toml",
    ".json", ".yaml", ".yml", ".css", ".scss", ".py", ".txt",
    ".md", ".js", ".ts", ".html", ".xml", ".rc", ".theme"
}
DEPS = {
    "git": "git",
    "swaync": "swaync",
    "kitty": "kitty",
    "waybar": "waybar",
    "fuzzel": "fuzzel",
    "wallust": "wallust",
    "hyprctl": "hyprland",
    "hyprpaper": "hyprpaper",
    "hyprshutdown": "hyprshutdown",
}
SERVICES = ["hyprpaper.service"]

# =========================================================
# Logging Helpers
# =========================================================
def log(msg): print(f"ℹ️  {msg}")
def warn(msg): print(f"⚠️  {msg}", file=sys.stderr)
def err(msg): print(f"❌ {msg}", file=sys.stderr)

def run_cmd(cmd, **kwargs):
    """Execute command, respecting DRY_RUN and VERBOSE."""
    if isinstance(cmd, str):
        cmd = cmd.split()
    cmd_str = " ".join(str(c) for c in cmd)
    if DRY_RUN:
        print(f"[dry-run] {cmd_str}")
        return 0
    if VERBOSE:
        log(f"Running: {cmd_str}")
    try:
        result = subprocess.run(cmd, **kwargs)
        return result.returncode
    except FileNotFoundError:
        warn(f"Command not found: {cmd[0]}")
        return 1
    except Exception as e:
        warn(f"Command failed: {cmd_str} — {e}")
        return 1

# =========================================================
# Core Functions
# =========================================================
def is_hyprland() -> bool:
    """Detect if running under Hyprland."""
    desktop = os.environ.get("XDG_CURRENT_DESKTOP", "").lower()
    if "hyprland" in desktop:
        return True
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        return True
    if shutil.which("hyprctl"):
        try:
            subprocess.run(
                ["hyprctl", "version"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True
            )
            return True
        except subprocess.CalledProcessError:
            pass
    return False

def check_dependencies():
    """Check for required binaries; return list of missing packages."""
    if SKIP_DEPS:
        warn("Skipping dependency checks (SKIP_DEPS=1)")
        return []

    missing = []
    for binary, pkg in DEPS.items():
        if shutil.which(binary):
            if VERBOSE: log(f"✅ Found: {binary}")
        else:
            warn(f"Missing: {binary} (package: {pkg})")
            missing.append(pkg)

    if missing:
        err("Missing dependencies:")
        for pkg in missing:
            print(f" - {pkg}")
        print()
        if shutil.which("pacman"):
            print("💡 Install with:")
            print(f"paru/yay -S {' '.join(missing)}")
        elif shutil.which("apt"):
            print("💡 Install with:")
            print(f"sudo apt install {' '.join(missing)}")
        print()
        print("🔁 Or bypass checks with:")
        print("SKIP_DEPS=1 ./install.py")
        sys.exit(1)

    log("✅ All dependencies satisfied")
    return []

def backup_configs(backup_stamp: str):
    """Backup existing config directories."""
    log("📦 Backing up existing configurations...")
    for dir_name in CONFIG_DIRS:
        src = Path.home() / ".config" / dir_name
        if src.is_dir():
            dest = Path.home() / ".config" / f"{dir_name}.bak.{backup_stamp}"
            if DRY_RUN:
                print(f"[dry-run] mv {src} {dest}")
            else:
                shutil.move(str(src), str(dest))
                if VERBOSE: log(f"Backed up: {dir_name}")

def replace_home_placeholder(target_dir: Path):
    """Replace {HOME} placeholder with actual $HOME in text files."""
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

def deploy_configs(repo_path: Path):
    """Copy config directories from repo to ~/.config."""
    log("📥 Deploying configurations...")
    for dir_name in CONFIG_DIRS:
        src = repo_path / dir_name
        dest = Path.home() / ".config" / dir_name
        if src.is_dir():
            dest.mkdir(parents=True, exist_ok=True)
            if DRY_RUN:
                print(f"[dry-run] cp -a {src}/. {dest}/")
            else:
                shutil.copytree(str(src), str(dest), dirs_exist_ok=True)
                if VERBOSE: log(f"Deployed: {dir_name}")

    # Replace {HOME} placeholders after deploy
    log("🔧 Resolving {HOME} placeholders...")
    for dir_name in CONFIG_DIRS:
        dest = Path.home() / ".config" / dir_name
        if dest.is_dir():
            replace_home_placeholder(dest)

def deploy_wallpapers(repo_path: Path):
    """Copy wallpapers directory."""
    src = repo_path / "wallpapers"
    dest = Path.home() / "wallpapers"
    if src.is_dir():
        dest.mkdir(parents=True, exist_ok=True)
        if DRY_RUN:
            print(f"[dry-run] cp -a {src}/. {dest}/")
        else:
            shutil.copytree(str(src), str(dest), dirs_exist_ok=True)
            # Also replace placeholders in wallpaper dir (in case of config files)
            replace_home_placeholder(dest)
        log("🖼️  Wallpapers deployed")

def configure_services():
    """Enable/start systemd user services."""
    if not shutil.which("systemctl"):
        return

    log("⚙️  Configuring user services...")
    for service in SERVICES:
        try:
            # Check if service file exists
            result = subprocess.run(
                ["systemctl", "--user", "list-unit-files"],
                capture_output=True, text=True, check=False
            )
            if service not in result.stdout:
                warn(f"Service not found: {service}")
                continue

            if DRY_RUN:
                print(f"[dry-run] systemctl --user enable {service}")
                print(f"[dry-run] systemctl --user start/restart {service}")
            else:
                run_cmd(["systemctl", "--user", "enable", service])
                # Check if already active
                active = subprocess.run(
                    ["systemctl", "--user", "is-active", "--quiet", service],
                    check=False
                ).returncode == 0
                if active:
                    run_cmd(["systemctl", "--user", "restart", service])
                else:
                    run_cmd(["systemctl", "--user", "start", service])

            if VERBOSE: log(f"Enabled: {service}")
        except Exception as e:
            warn(f"Failed to configure {service}: {e}")

# =========================================================
# Main Execution
# =========================================================
def main():
    # Ensure config directory exists
    Path.home().joinpath(".config").mkdir(parents=True, exist_ok=True)

    # Hyprland environment check
    if not is_hyprland() and not SKIP_DEPS:
        err("This setup requires Hyprland.")
        err(f"Detected: XDG_CURRENT_DESKTOP='{os.environ.get('XDG_CURRENT_DESKTOP', 'unset')}'")
        sys.exit(1)

    if VERBOSE:
        log("✅ Hyprland environment detected")

    # Check dependencies
    check_dependencies()

    # Generate backup timestamp
    backup_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # Backup existing configs
    backup_configs(backup_stamp)

    # Clone repository to temp directory
    log("🌐 Cloning repository...")
    with tempfile.TemporaryDirectory() as temp_repo:
        repo_path = Path(temp_repo)
        run_cmd([
            "git", "clone", "--depth", "1", "--branch", REPO_BRANCH,
            REPO_URL, str(repo_path)
        ], check=True)

        # Deploy configs and wallpapers
        deploy_configs(repo_path)
        deploy_wallpapers(repo_path)

        # Configure systemd services (after files are in place)
        configure_services()

    # Final message
    print()
    log("✨ Installation complete")
    print()
    print("Apply changes with:")
    print("  hyprctl reload")
    print()
    print("You may also want to restart:")
    print("  • kitty")
    print("  • waybar")
    print("  • dunst")
    print("  • fuzzel")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        warn("Interrupted by user")
        sys.exit(130)
    except subprocess.CalledProcessError as e:
        err(f"Command failed with exit code {e.returncode}")
        sys.exit(e.returncode)
    except Exception as e:
        err(f"Unexpected error: {e}")
        if VERBOSE:
            import traceback
            traceback.print_exc()
        sys.exit(1)