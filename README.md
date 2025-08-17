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
mkdir -p ~/.local/bin
mv kraiser.sh ~/.local/bin/kraiser  # Rename to use 'kraiser' as a command
```

Ensure that `~/.local/bin` is in your `$PATH`. If not, you can add it to your `.bashrc` or `.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
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

- **identifier**: A unique, short key you will use in the kraiser command (e.g., `firefox`).
- **Window Name or Class Part**: This is the key for finding your window. It can be:
    * A **distinctive part of the window title** (e.g., "Writer" for "Document - LibreOffice Writer"). This is useful for applications with dynamic titles.
    * The **Window Class (WM_CLASS)**, which is often a more stable identifier (e.g., "konsole" for Konsole, or "Navigator" for Firefox's main window class). Using the class is generally recommended for reliability.
- **Executable Path**: The full path to the binary or command that initiates the application.
- **Associated Process Name**: A distinctive part of the application's process name (you can find it by running `ps aux | grep <app_name>`).

### How to Find Window and Process Details in KDE

#### 🧪 Quick Method: Use `kraiser --genconf` to extract almost config-ready info from open apps

Run:

```
kraiser --genconf
```

This will list currently open windows and generate **almost** config-ready lines you can copy directly into your `apps.conf`. You’ll usually need to adjust the window title or class to make it more reliable.

💡 **Tip:** Redirect the output to a temporary file for easier copy-pasting:

```
kraiser --genconf > ~/apps.conf.suggested
```

Then open it, review, and selectively copy the entries you want into your real config at:

```
~/.config/kraiser/apps.conf
```

⚠️ **Do not redirect directly into `apps.conf`**, as this would overwrite your existing configuration.

---

#### 🛠️ Manual Method: KDE’s built-in tools

Use this approach if you prefer to manually inspect window properties and process details. KDE Plasma provides built-in tools to help you identify the necessary information for your `apps.conf` entries.

To accurately configure new applications, you'll need to identify their **Window Name (or title part)**, **Window Class**, **Executable Path**, and **Associated Process Name**. KDE Plasma provides a helpful tool for this:

1. Open the application you wish to configure (e.g., a new browser, game, or utility).  
2. Go to **System Settings → Window Management → Window Rules**.  
3. Click the **"Add New..."** button.  
4. In the "Window matching" tab, click the **"Detect Window Properties"** button (magnifying glass icon).  
5. Click on the open application's window you want to configure.  
6. A window will appear showing various properties:
    * **`Window Name or Class Part`**: Use the window title for dynamic parts or **Window Class (role)** for a more stable identifier (e.g., `konsole` or `Navigator`).  
    * **`Executable Path`** and **`Associated Process Name`**: Often inferable from the app name, but for exactness, run in terminal:

      ```
      ps aux | grep <name_of_the_app_guess>
      ```

### Default examples found in `apps.conf`

```bash
# Example of a simple application using its class name
apps["dolphin"]="Dolphin|/usr/bin/dolphin|dolphin"

# Example of an Electron application
apps["crunchyroll"]="Crunchyroll|/usr/bin/crunchyroll|electron"

# Example of a Chromium PWA (<profile-directory> <app ID>)
apps["github"]="Github|/usr/bin/chromium --profile-directory=Default --app-id=hnpfjnhllnonngcglapefqaidbinmjnm|chromium"

# Example of a Firefox using a PWA a title part (replace <YOUR_PWA_ID> with the actual ID)
apps["gmail"]="Gmail|/usr/bin/firefoxpwa site launch <YOUR_PWA_ID>|firefoxpwa"

# Example of a Flatpak application. Use a part of its window title if WM_CLASS is empty or unreliable.
apps["chatterino"]="Chatterino|flatpak run com.chatterino.chatterino|chatterino"

# Add your custom applications below:

```

## 🤔 Why kraiser?

While you can launch applications directly with their command name, **kraiser** adds a layer of intelligence: it prevents multiple windows of the same app from cluttering your workspace and lets you instantly switch to the one you need. Instead of cycling endlessly through windows with Alt+Tab, you can jump straight to your desired app using a custom keyboard shortcut—cleaner, faster, and more focused.

