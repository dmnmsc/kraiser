#!/bin/bash
# 🚀 Launch an application if it's not running, or bring it to the foreground if it already is

# ℹ️ Requirements: This script needs 'kdotool'.
# 📌 Install it with: sudo apt install kdotool (Debian/Ubuntu) | yay -S kdotool(Arch)

# 🖥️ Keyboard Shortcuts in KDE:
# To launch or activate an application with a key combination:
# 1️⃣ Open System Settings → Keyboard → Keyboard Shortcuts.
# 2️⃣ Click Add New → Command or URL.
# 3️⃣ Enter the script path with the app identifier:
#    ~/bin/kraiser kate.
# 4️⃣ Assign a name to the shortcut (Example: 'Kate kraiser')
# 5️⃣ Define the key combination in the Shortcuts tab and apply changes.

# 🖥️ For GNOME:
# The Happy Appy Hotkey extension is recommended:
# 📌 https://extensions.gnome.org/extension/6057/happy-appy-hotkey/
# 1️⃣ Install the extension from the GNOME Extensions page.
# 2️⃣ Activate it and use the settings to add custom shortcuts.

# ✅ Verify if `kdotool` is installed before running the script
if ! command -v kdotool &>/dev/null; then
    echo "❌ Error: 'kdotool' is not installed. Please install it for the script to work correctly."
    exit 1
fi

# 📌 In-memory cache (tmpfs)
CACHE_FILE="/dev/shm/window_ids_cache" # Optimizes window activation

# ⚙️ Config File.  It will be created automatically if it doesn't exist.
APP_CONFIG_DIR="$HOME/.config/kraiser"
APP_CONFIG_FILE="$APP_CONFIG_DIR/apps.conf"

# Create a default application configuration file
create_default_config() {
    mkdir -p "$APP_CONFIG_DIR"
    cat << EOF > "$APP_CONFIG_FILE"
# Application configurations for kraiser
# Format: apps["identifier"]="Window Name|Executable Path|Associated Process Name"

# Example of a simple application
apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"

# Example of an Electron application
apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"

# Example of a Chromium PWA (<profile-directory> <app ID>)
apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"

# Example of a Firefox PWA (replace <YOUR_PWA_ID> with the actual ID)
apps["gmail"]="Gmail|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"

# Add your custom applications below:
EOF
    echo "ℹ️ Default application configuration file created at $APP_CONFIG_FILE"
}

# 🗒️ Check if the config file exists, otherwise create it
if [[ ! -f "$APP_CONFIG_FILE" ]]; then
    create_default_config
fi

# 📤 Load application definitions from the config file
declare -A apps # Ensure the associative array is declared before sourcing
source "$APP_CONFIG_FILE"

# ✅ Validate the argument
APP_KEY="$1"
IFS='|' read -r APP_NAME APP_CMD APP_PROCESS <<< "${apps[$APP_KEY]}"

if [[ -z "$APP_NAME" || -z "$APP_CMD" || -z "$APP_PROCESS" ]]; then
    echo "❌ Unrecognized application: $APP_KEY"
    echo "Please ensure '$APP_KEY' is defined in your configuration file: $APP_CONFIG_FILE"
    exit 1
fi

# 🪓 Split APP_CMD into an array of arguments.
read -r -a APP_CMD_ARGS <<< "$APP_CMD"

# 🔎 Check if we already have the ID in cache
CACHED_ID=$(grep "^$APP_KEY:" "$CACHE_FILE" 2>/dev/null | cut -d ':' -f2)

# 🚀 If the cached ID is valid, activate it directly
if [[ -n "$CACHED_ID" && $(kdotool search | grep -w "$CACHED_ID") ]]; then
    kdotool windowactivate "$CACHED_ID"
    echo "✔ Activating window from RAM cache: $APP_NAME"
    exit 0
fi

# 🔍 Search for active window with process filtering
WINDOW_ID=$(kdotool search | while read id; do
    if kdotool getwindowname "$id" | grep -qi "$APP_NAME"; then
        PID=$(kdotool getwindowpid "$id")
        PROCESS_NAME=$(ps -p "$PID" -o args= | tr -d '\n')

        if [[ "$PROCESS_NAME" == *"$APP_PROCESS"* ]]; then
            echo "$id"
            break
        fi
    fi
done)

if [ -n "$WINDOW_ID" ]; then
    # 💾 Save the ID to RAM cache for quick future activations
    sed -i "/^$APP_KEY:/d" "$CACHE_FILE" 2>/dev/null
    echo "$APP_KEY:$WINDOW_ID" >> "$CACHE_FILE"

    kdotool windowactivate "$WINDOW_ID"
    echo "✔ Activating window and caching to RAM: $APP_NAME"
else
    echo "🚀 Launching $APP_NAME"
    nohup "${APP_CMD_ARGS[@]}" >/dev/null 2>&1 &
fi
