# 🚀 kraiser - KDE Application Launcher & Activator

### 🧠 Launch an app if it’s not running, or bring it to the front if it is

**kraiser** is a Bash script for KDE Plasma that opens an app if it’s not running—or brings it to the foreground if it is. No more extra clicks, wasted time, or window clutter.

Built to streamline your workflow, kraiser supports a wide range of app types: standard desktop apps, Electron-based tools, PWAs (via Firefox or Chromium), and more. Configuration is simple and flexible through a single `apps.conf` file.

Forget cycling endlessly through windows with Alt+Tab. With kraiser, you can jump straight to the app you need using a custom keyboard shortcut. Cleaner, faster, and more focused.

**Just Run or Raise.**

## 🧩 Key Features

- 🖥️ **Run or Raise**: Opens an app if it’s not running—or brings it to the front if it is  
- ⚡ **Fast Activation**: Uses in-memory RAM cache (`/dev/shm`) for near-instant response  
- 🧩 **Versatile Support**: Works with desktop apps, Electron tools, PWAs, and more  
- ⚙️ **Simple Configuration**: Manage apps easily via a single `apps.conf` file  
- 🪟 **KDE-Optimized**: Built for KDE Plasma, leveraging `kdotool`  
- ⌨️ **Keyboard-Friendly**: Integrates seamlessly with custom shortcuts


## 🖥️ Desktop Compatibility

**kraiser** is built specifically for **KDE Plasma** and depends on KDE tools like `kdotool` for window management and activation.

### 🧠 Note for GNOME Users

If you're using **GNOME** instead of KDE Plasma, there's a fantastic extension called [Happy Appy Hotkey](https://extensions.gnome.org/extension/6057/happy-appy-hotkey/) that offers a more complete and polished solution for launching and focusing applications via keyboard shortcuts. It's specifically designed for GNOME and performs this functionality even better than this script.

## 🛠️ Requirements

- **kdotool**: This utility is essential for interacting with windows in KDE.

### Debian/Ubuntu

```bash
sudo apt install kdotool
```

### Arch Linux

```bash
yay -S kdotool
```

## 📦 Installation

Clone the repository:

```bash
git clone https://github.com/dmnmsc/kraiser.git
cd kraiser
```

Make the script executable:

```bash
chmod +x kraiser.sh
```

Move the script to your PATH (optional, but recommended):

```bash
mkdir -p ~/bin
mv kraiser.sh ~/bin/kraiser  # Rename to use 'kraiser' as a command
```

Ensure that `~/bin` is in your `$PATH`. If not, you can add it to your `.bashrc` or `.zshrc`:

```bash
export PATH="$HOME/bin:$PATH"
source ~/.bashrc
```

Test it!
```bash
kraiser dolphin
```

## ⌨️ Usage with Keyboard Shortcuts in KDE Plasma

kraiser shines when integrated with your KDE keyboard shortcuts to launch or activate your favorite applications with a single key combination.

1. Open **System Settings → Keyboard → Keyboard Shortcuts**.
2. Click **Add New → Command or URL**.
3. Enter the full path to your script with the application identifier. For example, to launch Dolphin:

   ```bash
   ~/bin/kraiser dolphin
   ```

4. Assign a descriptive name to the shortcut (e.g., Dolphin kraiser).
5. Define the key combination in the **Shortcuts** tab and apply the changes.

## ⚙️ Application Configuration

Application definitions are managed in a separate configuration file to allow for easy customization.

### Configuration File Location

kraiser will automatically create a default configuration file at `~/.config/kraiser/apps.conf` if it doesn't already exist.

### Configuration File Format

Edit `~/.config/kraiser/apps.conf` to define your applications. Each entry follows the format:

```bash
apps["identifier"]="Window Name|Executable Path|Associated Process Name"
```

- **identifier**: A unique, short key you will use in the kraiser command (e.g., `kraiser firefox`).
- **Window Name**: The exact title or a significant part of the application's window title.
- **Executable Path**: The full path to the binary or command that initiates the application.
- **Associated Process Name**: A distinctive part of the application's process name (you can find it by running `ps aux | grep <app_name>`).

### How to Find Window and Process Details in KDE

To accurately configure new applications, you'll need to identify their Window Name, Executable Path, and Associated Process Name. KDE Plasma provides a helpful tool for this:

1. Open the application you wish to configure (e.g., a new browser, game, or utility).
2. Go to **System Settings → Window Management → Window Rules**.
3. Click the **Add New...** button.
4. In the **Window matching** tab, click the **Detect Window Properties** button (often represented by a crosshair icon).
5. Click on the open application's window that you want to configure.
6. A new window will appear, showing various properties of that window. You can find the **Window Class (role)** or **Window title** for your Window Name. For the Executable Path and Associated Process Name, look for properties related to the process or application name/command.

### Default examples found in `apps.conf`

```bash
# Example of a simple application
apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"

# Example of an Electron application
apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"

# Example of a Chromium PWA (<profile-directory> <app ID>)
apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"

# Example of a Firefox PWA (replace <YOUR_PWA_ID> with the actual ID)
apps["gmail"]="Gmail|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"

```

## 🤔 Why kraiser?

While you can launch applications directly with their command name, **kraiser** adds a layer of intelligence: it prevents multiple windows of the same app from cluttering your workspace and lets you instantly switch to the one you need. Instead of cycling endlessly through windows with Alt+Tab, you can jump straight to your desired app using a custom keyboard shortcut—cleaner, faster, and more focused.

