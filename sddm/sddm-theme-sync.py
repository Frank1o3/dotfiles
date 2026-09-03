#!/usr/bin/env python3
"""
Syncs the current wallust-generated wallpaper/colors into the SDDM theme.
Runs as root, triggered by a systemd path unit watching the live wallpaper.

EDIT USER_HOME BELOW to match your username before installing.
"""
import json
import shutil
from pathlib import Path

USER_HOME = Path("/home/franklin")  # <-- EDIT ME
COLORS_JSON = USER_HOME / ".config/quickshell/colors.json"
WALLPAPER = USER_HOME / "wallpapers/wallpaper.jpg"

THEME_DIR = Path("/usr/share/sddm/themes/quickshell-glass")
BG_DEST = THEME_DIR / "backgrounds/current.jpg"
CONF_DEST = THEME_DIR / "theme.conf.user"


def main():
    if not COLORS_JSON.exists() or not WALLPAPER.exists():
        print("colors.json or wallpaper not found, skipping")
        return

    data = json.loads(COLORS_JSON.read_text())

    BG_DEST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(WALLPAPER, BG_DEST)
    BG_DEST.chmod(0o644)

    colors = data.get("colors", [])
    accent = colors[4] if len(colors) > 4 else data.get("foreground", "#cdd6f4")
    border = colors[5] if len(colors) > 5 else data.get("background", "#1e1e2e")

    conf = f"""[General]
background=backgrounds/current.jpg
colorBackground={data.get("background", "#1e1e2e")}
colorForeground={data.get("foreground", "#cdd6f4")}
colorAccent={accent}
colorBorder={border}
"""
    CONF_DEST.write_text(conf)
    CONF_DEST.chmod(0o644)
    print("SDDM theme synced")


if __name__ == "__main__":
    main()