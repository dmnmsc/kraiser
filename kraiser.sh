
#!/bin/bash
# 🚀 Launch an application if it's not running, or bring it to the foreground if it already is

# ℹ️ Requirements: This script needs 'kdotool'.
# 📌 Install it with: sudo apt install kdotool (Debian/Ubuntu) | yay -S kdotool-git (Arch)

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

# ⚙️ Config File. It will be created automatically if it doesn't exist.
APP_CONFIG_DIR="$HOME/.config/kraiser"
APP_CONFIG_FILE="$APP_CONFIG_DIR/apps.conf"

# Create a default application configuration file
create_default_config() {
    mkdir -p "$APP_CONFIG_DIR"
    cat << EOF > "$APP_CONFIG_FILE"
# Application configurations for kraiser
# Format: apps["identifier"]="Window Name or Class Part|Executable Path|Associated Process Name"
#
# 'Window Name or Class Part' can be:
#  - A distinctive part of the window title (e.g., "LibreOffice Writer" for dynamic titles)
#  - The window class (WM_CLASS), which is often more stable (e.g., "konsole" for Konsole)
#  - For Flatpak/Snap apps where WM_CLASS might not be consistently exposed,
#    use a reliable part of the window title instead.

# Example of a simple application using its class name
apps["dolphin"]="dolphin|/usr/bin/konsole|dolphin"

# Example of an Electron application
apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"

# Example of a Chromium PWA (<profile-directory> <app ID>)
apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"

# Example of a Firefox PWA using a title part (replace <YOUR_PWA_ID> with the actual ID)
apps["youtube"]="YouTube|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"

# Example of a Flatpak application. Use a part of its window title if WM_CLASS is empty or unreliable.
apps["chatterino"]="Chatterino|flatpak run com.chatterino.chatterino|chatterino"

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
IFS='|' read -r APP_NAME_OR_CLASS APP_CMD APP_PROCESS <<< "${apps[$APP_KEY]}"

if [[ -z "$APP_NAME_OR_CLASS" || -z "$APP_CMD" || -z "$APP_PROCESS" ]]; then
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
    echo "✔ Activating window from RAM cache: $APP_NAME_OR_CLASS"
    exit 0
fi

# 🔍 Search for active window by matching process name AND (window title OR window class).
WINDOW_ID="" # Reset WINDOW_ID for the actual search
WINDOW_ID=$(kdotool search | while read id; do
    PID=$(kdotool getwindowpid "$id" 2>/dev/null)
    PROCESS_NAME=$(ps -p "$PID" -o args= | tr -d '\n' 2>/dev/null)

    # Primary check: If the process name contains the target process name.
    if [[ "$PROCESS_NAME" == *"$APP_PROCESS"* ]]; then
        WINDOW_TITLE=$(kdotool getwindowname "$id" 2>/dev/null)
        WINDOW_CLASS=$(kdotool getwindowclass "$id" 2>/dev/null)

        # Secondary check: Validate against window title or class.
        # This is the critical part for distinguishing between multiple instances
        # of the same process (like different Firefox PWAs), or for confirming
        # the specific Flatpak instance.
        if [[ "$WINDOW_TITLE" =~ "$APP_NAME_OR_CLASS" || "$WINDOW_CLASS" =~ "$APP_NAME_OR_CLASS" ]]; then
            echo "$id"
            break # Found a precise match, exit the loop
        fi
    fi
done)

if [ -n "$WINDOW_ID" ]; then
    # 💾 Save the ID to RAM cache for quick future activations
    sed -i "/^$APP_KEY:/d" "$CACHE_FILE" 2>/dev/null
    echo "$APP_KEY:$WINDOW_ID" >> "$CACHE_FILE"

    kdotool windowactivate "$WINDOW_ID"
    echo "✔ Activating window and caching to RAM: $APP_NAME_OR_CLASS"
else
    echo "🚀 Lanzando $APP_NAME_OR_CLASS"
    # Using array expansion for robust command execution
    nohup "${APP_CMD_ARGS[@]}" >/dev/null 2>&1 &
fi
