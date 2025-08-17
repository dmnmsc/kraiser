# 📝 CHANGELOG

This document outlines the significant changes and improvements made to the `kraiser` script across its development iterations.

## v1.1 - 2025-08-17 (Enhanced Window Detection & Flatpak Support)

This version focuses on improving the reliability of window detection, especially for applications like Flatpaks and Firefox PWAs.

### 🚀 Improvements

* **Robust Window Matching**:

  * The window search logic (`kdotool search | while read id; do ... done)`) has been significantly enhanced.

  * It now retrieves both the **Window Title** and **Window Class (WM_CLASS)** for each window.

  * The matching condition (`if [[ "$WINDOW_TITLE" =~ "$APP_NAME_OR_CLASS" || "$WINDOW_CLASS" =~ "$APP_NAME_OR_CLASS" ]]`) now robustly checks `APP_NAME_OR_CLASS` against either the window's title or its class (which is often more stable for apps like Konsole).

  * Crucially, the script now prioritizes matching the **`Associated Process Name`** (`APP_PROCESS`) first, and then uses the title/class as a secondary confirmation. This is vital for applications where `kdotool` might return empty window title/class, or for distinguishing between multiple instances of the same process (e.g., several Firefox PWAs).

* **Improved Flatpak Compatibility**: The refined window detection logic directly addresses issues with Flatpak applications like Chatterino, which previously failed to activate existing instances due to inconsistent window property exposure.


### ⚙️ Configuration Examples in `apps.conf` (Updated)

* `APP_NAME` in the script was renamed to `APP_NAME_OR_CLASS` to better reflect its flexible use for matching both window titles and classes.

* Added and refined default examples in the `create_default_config` function to guide users on accurate configuration:

  * **Simple Apps**: `apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"` (now using class name for Konsole).

  * **Electron Apps**: `apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"`

  * **Chromium PWAs**: `apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"`

  * **Firefox PWAs**: `apps["gmail"]="Gmail|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"` and `apps["youtube"]="YouTube|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"`

  * **Flatpaks**: `apps["chatterino"]="Chatterino|flatpak run com.chatterino.chatterino|chatterino"`.


## v1.0 - 2025-08-17 (Initial Release)

This marks the first public release of the `kraiser` script.

### ✨ Features

* **Core Functionality**: Launch an application if it's not running, or bring its existing window to the foreground.

* **`kdotool` Dependency**: Leverages `kdotool` for window manipulation on KDE Plasma.

* **In-Memory Cache**: Utilizes `/dev/shm` for fast caching of window IDs, speeding up subsequent activations.

* **External Configuration**: Application definitions are stored in `~/.config/kraiser/apps.conf` for easy customization without modifying the main script.

* **KDE Shortcut Guidance**: Includes instructions for setting up keyboard shortcuts in KDE Plasma..

* **Basic Application Detection**: Identifies windows primarily by their title and associated process name.

### ⚙️ Configuration Examples in `apps.conf` (Initial)

* `apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"`

* `apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"`

* `apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"`

* `apps["gmail"]="Gmail|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"`
