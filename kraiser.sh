#!/bin/bash
# 🚀 Launch an application if it's not running, or bring it to the foreground if it already is

# ℹ️ Requirements: This script needs 'kdotool'.
# 📌 Install it with: sudo apt install kdotool (Debian/Ubuntu) | yay -S kdotool (Arch)

# ✅ Verify if `kdotool` is installed before running the script
if ! command -v kdotool &>/dev/null; then
    echo "❌ Error: 'kdotool' is not installed. Please install it before using this script."
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
#   - A distinctive part of the window title (e.g., "LibreOffice Writer" for dynamic titles)
#   - The window class (WM_CLASS), which is often more stable (e.g., "konsole" for Konsole)
#   - For Flatpak/Snap apps where WM_CLASS might not be consistently exposed,
#     use a reliable part of the window title instead.
#
# You can generate a suggested template using:
#   ./kraiser.sh --genconf
#
# You can list currently open windows with:
#   ./kraiser.sh --list
#

# Example of a simple application using its class name
apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"

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
declare -A apps
source "$APP_CONFIG_FILE"

# --- 📜 Subcommands for inspection ---
case "$1" in
    --list)
        echo "🪟 Active windows detected:"
        for W in $(kdotool search --all ""); do
            TITLE=$(kdotool getwindowname "$W")
            CLASS=$(kdotool getwindowclassname "$W")
            PID=$(kdotool getwindowpid "$W")
            PROC=$(ps -o comm= -p "$PID" 2>/dev/null)
            printf 'ID: %s\n  Title: %s\n  Class: %s\n  PID: %s (%s)\n\n' \
                "$W" "$TITLE" "$CLASS" "$PID" "$PROC"
        done
        exit 0
        ;;

    --genconf)
        # Detect if stdout is a terminal
        if [ -t 1 ]; then
            YELLOW='\033[1;33m'
            GREEN='\033[1;32m'
            RESET='\033[0m'
        else
            YELLOW=''
            GREEN=''
            RESET=''
        fi

        echo -e "# 📑 Suggested template for ~/.config/kraiser/apps.conf"
        echo -e "# ⚠ This is a guide / template. Review and copy the lines you want into your apps.conf"
        echo -e "#   You may need to adjust window titles, identifiers, or executable paths!"
        echo

        declare -A NORMAL_APPS
        declare -A PWAS

        for W in $(kdotool search --all ""); do
            WINDOW_TITLE=$(kdotool getwindowname "$W" 2>/dev/null)
            WINDOW_CLASS=$(kdotool getwindowclassname "$W" 2>/dev/null)
            PID=$(kdotool getwindowpid "$W" 2>/dev/null)
            PROC=$(ps -o comm= -p "$PID" 2>/dev/null)
            TITLE_ESC=$(echo "$WINDOW_TITLE" | sed 's/"/\\"/g')

            # Detect FirefoxPWAs
            if [[ "$PROC" =~ firefoxpwa ]] || ([[ "$PROC" =~ firefox ]] && [[ "$WINDOW_TITLE" =~ Web|YouTube|Instagram|GitHub|Google|Microsoft|Comparación|WhatsApp ]]); then
                # Human-readable identifier: app name
                IDENT=$(echo "$WINDOW_TITLE" | awk '{print tolower($1)}' | tr -cd '[:alnum:]')
                # Extract pure ID: remove FFPWA- prefix
                PWA_ID=$(echo "$WINDOW_CLASS" | tr -cd '[:alnum:]-' | sed 's/^FFPWA-//')
                # Launch command
                CMD="/usr/bin/firefoxpwa site launch $PWA_ID"
                PWAS["$IDENT"]="$TITLE_ESC|$CMD|firefoxpwa"
            else
                IDENT=$(echo "$PROC" | tr '[:upper:]' '[:lower:]')
                CMD="/usr/bin/$PROC"
                NORMAL_APPS["$IDENT"]="$TITLE_ESC|$CMD|$PROC"
            fi
        done

        # Print normal apps
        echo -e "# Normal apps"
        for K in $(printf "%s\n" "${!NORMAL_APPS[@]}" | sort); do
            TITLE=$(echo "${NORMAL_APPS[$K]}" | cut -d'|' -f1)
            EXEC=$(echo "${NORMAL_APPS[$K]}" | cut -d'|' -f2)
            PROC=$(echo "${NORMAL_APPS[$K]}" | cut -d'|' -f3)
            echo -e "${YELLOW}apps[\"$K\"]${RESET}=\"$TITLE|${GREEN}$EXEC${RESET}|$PROC\"  # You may need to change title, identifier, or path"
            echo
        done

        echo
        # Print FirefoxPWAs
        echo -e "# FirefoxPWAs"
        for K in $(printf "%s\n" "${!PWAS[@]}" | sort); do
            TITLE=$(echo "${PWAS[$K]}" | cut -d'|' -f1)
            EXEC=$(echo "${PWAS[$K]}" | cut -d'|' -f2)
            PROC=$(echo "${PWAS[$K]}" | cut -d'|' -f3)
            echo -e "${YELLOW}apps[\"$K\"]${RESET}=\"$TITLE|${GREEN}$EXEC${RESET}|$PROC\"  # You may need to change title, identifier, or path"
            echo
        done

        exit 0
        ;;

    --help)
        echo "Usage: $0 <app_identifier> [options]"
        echo
        echo "Launch an application if it's not running, or bring its window to the foreground."
        echo
        echo "Options:"
        echo "  --list         List currently active windows with their IDs, titles, classes, and process names."
        echo "  --genconf      Generate a suggested configuration template for ~/.config/kraiser/apps.conf."
        echo "                 Extra tip: you can save the template directly to a file like this:"
        echo "                     $0 --genconf > apps.conf"
        echo "  --help         Show this help message and exit."
        exit 0
        ;;

    esac

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
WINDOW_ID=""
WINDOW_ID=$(kdotool search | while read id; do
    PID=$(kdotool getwindowpid "$id" 2>/dev/null)
    PROCESS_NAME=$(ps -p "$PID" -o args= | tr -d '\n' 2>/dev/null)

    if [[ "$PROCESS_NAME" == *"$APP_PROCESS"* ]]; then
        WINDOW_TITLE=$(kdotool getwindowname "$id" 2>/dev/null)
        WINDOW_CLASS=$(kdotool getwindowclass "$id" 2>/dev/null)

        if [[ "$WINDOW_TITLE" =~ "$APP_NAME_OR_CLASS" || "$WINDOW_CLASS" =~ "$APP_NAME_OR_CLASS" ]]; then
            echo "$id"
            break
        fi
    fi
done)

if [ -n "$WINDOW_ID" ]; then
    sed -i "/^$APP_KEY:/d" "$CACHE_FILE" 2>/dev/null
    echo "$APP_KEY:$WINDOW_ID" >> "$CACHE_FILE"

    kdotool windowactivate "$WINDOW_ID"
    echo "✔ Activating window and caching to RAM: $APP_NAME_OR_CLASS"
else
    echo "🚀 Launching $APP_NAME_OR_CLASS"
    nohup "${APP_CMD_ARGS[@]}" >/dev/null 2>&1 &
fi
