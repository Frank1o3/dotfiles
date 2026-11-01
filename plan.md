# Fluid Glass Desktop Rice Plan

## Goal

Bring the Hyprland desktop closer to the supplied Quickshell references: a calm, wallpaper-led glass look with a compact top bar, a unified command center, an animated wallpaper browser, and matching lock and login screens. Keep the setup practical, readable, keyboard-friendly, and installable through this repository's existing scripts.

The references suggest a dark translucent base with soft blur, rounded layered surfaces, thin bright edges, restrained highlights, and accents sampled from the wallpaper. The warm dashboard reference is useful for layout ideas; the overall palette should still follow the selected wallpaper rather than hard-code that image's colors.

## Current repository starting point

- Quickshell already has shared appearance and color singletons, reusable glass components, a bar, launcher, notifications, power menu, control center, and wallpaper picker.
- The control center currently presents Settings rows, but opening Wi-Fi, Bluetooth, or System Monitor closes it and opens a separate floating window. The intended experience is one panel whose content changes to a detail page, with a back action and a short transition.
- The wallpaper picker currently uses a thumbnail grid. The reference's centered, perspective/tilted carousel with pointer-driven movement is the target interaction to investigate.
- Hyprlock and an SDDM theme already exist. The SDDM theme uses Qt Quick 2.15 imports; its Qt version and the installed SDDM build need to be checked before choosing a Qt 6-only path.
- GTK 4 has local CSS overrides. GTK and Qt cannot share identical rendering, but their palette, typography, corner shapes, and dark appearance can be aligned.
- There are existing uncommitted changes in the worktree, including Quickshell UI/state files. Preserve and review those changes as the implementation proceeds.

## Desired experience

### Shared visual language

- Use one coherent token set for wallpaper-derived colors, text contrast, translucent surfaces, borders, corner radii, spacing, shadows, and animation timing.
- Establish clear surface depth: a readable tinted base, restrained blur where the compositor/toolkit supports it, a subtle top edge highlight, and a soft shadow. Avoid relying on transparency alone for legibility.
- Keep the bar compact and quiet. Let the larger panels carry the glass effect without reducing text or control contrast.
- Use the same type and icon choices across Quickshell, Hyprlock, SDDM, GTK, and Qt apps wherever the platform allows.

### Command center

- Keep overview content (quick toggles, essential controls, and settings destinations) in a single command-center window.
- Selecting Wi-Fi, Bluetooth, or System Monitor replaces the overview body with that destination inside the same panel. Provide a clear back control and animate the page transition.
- Preserve working network scanning/connection, Bluetooth device controls, audio/brightness controls, and live system statistics while integrating the pages.
- Handle unavailable devices and services with explicit empty/error states instead of blank panels.

### Wallpaper browser

- Evolve the existing picker toward the supplied coverflow reference: a centered active wallpaper, angled neighboring cards, depth, and pointer movement that shifts the carousel naturally. Keep a compact thumbnail grid available as a second browsing mode.
- Keep search/filtering, clear filenames, keyboard navigation, selection feedback, and the existing wallpaper application and Wallust path.
- Use an opening/closing transition that feels related to the wallpaper transition without making selection slow or disorienting.

### Lock and login

- Bring Hyprlock and SDDM into the same palette and glass language as Quickshell, including a blurred/dimmed wallpaper, centered readable controls, consistent typography, and restrained motion where supported.
- Check the exact SDDM package/build and theme engine available on the target system before deciding whether the theme can use Qt 6 directly. If Qt 6 is viable, update theme imports and dependencies together; otherwise document the compatible path rather than assuming Qt 6 support.
- Keep session actions and authentication usable with keyboard and across the expected display resolutions.

### GTK and Qt applications

- Set a consistent dark preference, font, icon theme, and accent/palette for both toolkits.
- Align GTK/libadwaita CSS and Qt theme configuration with the shared colors and typography. Treat exact visual parity as a goal, while respecting toolkit-specific rendering and theming limits.
- Identify the required Qt 6 platform style/theme packages and environment variables for the target desktop, and remove Qt 5 packages only after confirming no configured application or SDDM component needs them.

## Quickshell 0.3.2 documentation to attach

The supplied module list is for Quickshell 0.3.2. Verify the APIs against these versioned docs before changing QML that depends on them. Use only the modules needed by a feature; this is the complete available-module inventory, not a requirement to add imports for everything.

| Module / API | Quickshell 0.3.2 documentation | Planned relevance |
| --- | --- | --- |
| Quickshell | [Core Quickshell types](https://quickshell.org/docs/v0.3.2/types/Quickshell) | Shell root, windows, shared runtime |
| Quickshell.Bluetooth | [Bluetooth API](https://quickshell.org/docs/v0.3.2/types/Quickshell.Bluetooth) | Bluetooth controls and device states |
| Quickshell.DBusMenu | [DBusMenu types](https://quickshell.org/docs/v0.3.2/types/Quickshell.DBusMenu) | System tray menu integration |
| Quickshell.Hyprland | [Hyprland types](https://quickshell.org/docs/v0.3.2/types/Quickshell.Hyprland) | Hyprland integration and wallpaper focus behavior |
| Quickshell.I3 | [I3 types](https://quickshell.org/docs/v0.3.2/types/Quickshell.I3) | Available alternative WM integration; not a current target |
| Quickshell.Io | [Io types](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io) | Processes, files, and existing shell service helpers |
| Quickshell.Networking | [Network API](https://quickshell.org/docs/v0.3.2/types/Quickshell.Networking) | Wi-Fi scan, connection, and status page |
| Quickshell.Services.Greetd | [Greetd integration](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Greetd) | Future Veyra greeter feasibility investigation |
| Quickshell.Services.Mpris | [Mpris service](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Mpris) | Bar media controls and status |
| Quickshell.Services.Notifications | [Notification daemon types](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Notifications) | Notification surface and daemon integration |
| Quickshell.Services.Pam | [Pam authentication](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Pam) | Future greeter authentication feasibility investigation |
| Quickshell.Services.Pipewire | [Pipewire API](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Pipewire) | Audio controls and status |
| Quickshell.Services.Polkit | [Polkit agent](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.Polkit) | Privileged desktop authentication prompts |
| Quickshell.Services.SystemTray | [System tray types](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.SystemTray) | Bar tray items and menus |
| Quickshell.Services.UPower | [UPower service](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.UPower) | Battery status and power information |
| Quickshell.Wayland | [Wayland types](https://quickshell.org/docs/v0.3.2/types/Quickshell.Wayland) | Layer-shell surfaces, focus, and compositor integration |
| Quickshell.Widgets | [Bundled widgets](https://quickshell.org/docs/v0.3.2/types/Quickshell.Widgets) | Check for reusable built-in controls before duplicating them |
| Quickshell.WindowManager | [Window manager interface](https://quickshell.org/docs/v0.3.2/types/Quickshell.WindowManager) | Keep WM integration separable from shell UI where useful |

Record the output of `quickshell --version` (or the installed command's equivalent) during the compatibility inventory. The user reports version 0.3.2; verify on the target session before implementation.

## Work sequence

1. **Documentation and compatibility inventory** — consult relevant supplied 0.3.2 module docs; inspect the current QML, installed command versions, SDDM engine, Qt/GTK theme capabilities, and package names for the target distribution.
2. **Shared theme foundation** — consolidate visual tokens and wallpaper palette flow; align Quickshell components, Hyprlock, SDDM, GTK, and Qt settings around those tokens.
3. **Command-center navigation** — replace separate detail windows with an animated in-panel page stack, retaining functional service controls and adding empty/error states.
4. **Wallpaper coverflow** — build the perspective carousel and pointer/keyboard interaction on top of the current wallpaper listing/application path.
5. **Login and lock refinement** — complete matching backgrounds, surfaces, typography, controls, and resolution behavior after the target SDDM/Qt path is confirmed.
6. **Install and handoff integration** — update package and setup/sync documentation as needed; ensure the existing install flow applies the complete theme consistently.

## Later Veyra OS integration

The user is building Veyra OS, an Arch-based installation that uses this dotfiles repository. The Veyra source/ISO tree will be supplied after this plan update. Finish and review the rice first; then inspect Veyra's actual build and install flow before making OS-level changes.

Planned follow-up topics from the user (not yet investigated or implemented):

- Give Veyra its own boot/OS identity assets, including replacing the default Arch Linux icon where appropriate.
- Resolve missing ISO utilities such as `bsdtar`, locale configuration, and other installation details against the supplied profile and logs.
- Decide how AUR-sourced packages should be delivered and installed. Evaluate package-source and offline/cache constraints from the real ISO build; do not assume the live ISO contains a reusable pacstrap cache.
- Investigate Quickshell's `Quickshell.Services.Greetd` and `Quickshell.Services.Pam` APIs for a Veyra login greeter, including the service/session lifecycle, authentication, packaging, and failure recovery.
- Treat login and lock as separate responsibilities. Determine what would provide the post-login lock screen, and preserve the existing SDDM-based path on the user's CachyOS machine unless a compatible alternative is established.

The Greetd idea is a research question, not a selected design yet. Confirm the module's actual 0.3.2 capabilities and the Veyra boot/session architecture before deciding whether it can replace SDDM in that OS.

## Review checkpoints

- Each stage should be inspectable before moving to the next, with existing user edits preserved.
- Check QML with the installed Quickshell version and inspect the actual running desktop at the intended display scale; a successful parse/build alone does not establish that composition or animation looks right.
- Check GTK and Qt applications, Hyprlock, and the SDDM greeter separately. Validate the selected SDDM path in the installed environment before describing Qt 6 compatibility as complete.
- Check wallpaper changes end to end: selection, transition, palette regeneration, and propagation to the shell/lock/login themes.
- Keep dependency removal as a final cleanup after all configured consumers have been accounted for.

## Current status and pause point (2026-10-31)

The user added the inspiration repository at `../prism-shell`. Its bar and wallpaper approach have now been reviewed. Carry over the clear capsule hierarchy, restrained animation, and wallpaper-derived color accents as design cues; keep this repository's own identity and darker wallpaper collection, and do not import the reference's bright wallpaper assets. Keep changes in this dotfiles checkout unless the user asks to edit the reference repository.

The earlier plan stages have been implemented across the dotfiles: wallpaper-derived colors flow through Quickshell, Hyprlock, GTK 4, Qt 6, Kitty, and SDDM; the SDDM theme uses its Qt 6 greeter path and `qt6-5compat`; and setup installs toolkit preferences and generates an initial palette. The current Quickshell control center keeps Wi-Fi, Bluetooth, and System Monitor in the same panel. The latest navigation fix moved the selected page from a global singleton into each panel instance, so opening/closing a panel on another monitor cannot reset the page. A short Loader transition is retained. The wallpaper picker now has a compact thumbnail grid and a perspective shelf, plus search, keyboard browsing, filenames, and the existing wallpaper application path.

### Resume here

1. Inspect the rebuilt control center in a live session at the active display scale; verify the anchored title/date header stays clear of the Home cards and check wallpaper-derived contrast.
2. Exercise each dashboard destination (Home, Wi-Fi, Bluetooth, System Monitor), the page transitions, and closing/reopening the panel.
3. Check launcher search, result descriptions, recent apps, keyboard navigation, launch, and close behavior.
4. Review the wallpaper shelf and grid; confirm the active card, Apply button, and selection path work with the existing wallpaper script.
5. Confirm the Cava visualizer bars rise from a shared bottom baseline and inspect Quickshell startup logs for the Bluetooth null-device warning and any new QML errors.
6. Review and tune the unified top-bar capsule in a live session, especially on smaller displays.
7. Close the remaining review items, then update this status before moving to Veyra OS integration.

The top bar now uses one dark, high-contrast capsule with workspace navigation on the left, media and clock in the middle, and compact device/tray controls on the right. CPU and memory readouts no longer crowd the bar; live system statistics remain available in the control center. The control center now follows a wide dashboard pattern with a persistent navigation rail, overview cards, and dedicated Wi-Fi, Bluetooth, and system pages. The launcher now has a wider result list with application descriptions and improved keyboard cues. The wallpaper picker uses a larger active preview with a clear Apply action and dimmed backdrop. Cava bars are bottom-aligned so they grow upward, and Bluetooth's unavailable-adapter path no longer reads `devices` from null. These changes still need live-session review before calling the rice complete.

### Validation already recorded

Local inventory: Quickshell 0.3.2, Qt 6.12, SDDM 0.21.0, GTK 4.24.1. The `sddm --version` invocation aborts on this machine, so the package database and Qt 6 linkage were used as evidence. Earlier `qmllint`, shell/Lua/Python syntax checks, `git diff --check`, isolated Wallust palette generation, Quickshell runtime loading, and an SDDM Qt 6 staged-theme preview passed. The recent Quickshell navigation and wallpaper picker QML also passed `qmllint`. Authentication and a real display-manager session were not exercised; GTK/Qt app windows and Hyprlock were not launched for visual review. Existing worktree edits remain uncommitted and must be preserved. Review and install this rice before making OS-level changes in Veyra.
