
# Countdown Timer Bar

A lightweight and customizable KDE Plasma 6 widget that displays a countdown as a progress indicator.

The widget uses a horizontal progress bar when displayed in its expanded representation and a circular progress indicator in its compact representation, making it suitable for both horizontal and vertical panels.

The timer gradually decreases as time passes. When it reaches zero, the progress indicator changes to the configured expiration color and starts blinking.

The widget supports pausing and resuming the countdown, desktop notifications, and persistent timer state across Plasma restarts.

## Features

- **Visual countdown:** a horizontal progress bar in the expanded representation and a circular progress indicator in the compact representation.
- **Panel orientation support:** adapts to horizontal and vertical panels through Plasma's compact and expanded representations.
- **Expiration indicator:** the progress indicator changes to the configured expiration color and blinks when the countdown expires.
- **Desktop notifications:** optionally sends a notification when the countdown expires.
- **Pause and resume:** temporarily pause the countdown and resume it later.
- **Persistent timer:** restores the timer state after Plasma restarts, including the remaining time and pause state.
- **Automatic reset after long inactivity:** automatically starts a fresh countdown if the previous timer has been expired for more than twice its configured duration.
- **Compact representation:** displays the remaining time or percentage in the center of the circular indicator, depending on the configuration.
- **Configurable appearance and behavior:**
  - Countdown duration, from 1 second to 24 hours.
  - Normal and expired progress indicator colors.
  - Reset button text and KDE icon.
  - Show or hide the reset button icon.
  - Show or hide the remaining time.
  - Show or hide the countdown percentage.
  - Enable or disable pause and resume.
  - Enable or disable expiration notifications.
- **Conditional reset button:** automatically hides the reset button when both its text and icon are empty or disabled.
- **Context-aware reset interaction:**
  - When the reset button is visible, clicking the compact indicator opens the expanded representation.
  - When the reset button is hidden, clicking the progress indicator directly resets the timer.
  - Clicking the expanded progress bar resets the timer only when the reset button is hidden.

## Requirements

- KDE Plasma 6.
- `kpackagetool6` to install and uninstall the widget.
- `plasmoidviewer` to run the widget during development.
- `notify-send` for desktop notifications.
- `jq` for the uninstall script.
- `gettext` for building translations.

On Arch Linux, these tools are commonly available through KDE Plasma, `libnotify`, `jq`, and `gettext` packages. Package names may vary by distribution.

## Installation

Clone or download this repository, then run the installer from the project directory:

```bash
git clone https://github.com/dsabre/kde-countdown-timer-bar.git
cd kde-countdown-timer-bar
./install.sh
```

The installer builds the available translations and installs the Plasma package using:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

After installation, add **Countdown Timer Bar** to your desktop or panel using Plasma's normal widget-adding interface.

The widget automatically uses the appropriate representation depending on the available space:

- **Expanded representation:** horizontal progress bar with timer controls.
- **Compact representation:** circular progress indicator, suitable for narrow and vertical panels.

## Configuration

Open the widget's configuration dialog to customize its behavior.

### General

| Setting | Description | Default |
|---|---|---|
| Total seconds | Countdown duration, from 1 to 86,400 seconds | 3,600 (1 hour) |
| Final message | Message displayed in the expiration notification | `TIME'S UP!` |
| Expiration notification | Enable or disable the desktop notification | Enabled |

### Appearance

| Setting | Description | Default |
|---|---|---|
| Bar color | Color of the progress indicator while the timer is running | `#00a6f4` |
| Expired bar color | Color used when the countdown expires | `#ff0000` |
| Button text | Label displayed on the reset button | `Reset` |
| Button icon | KDE/System icon name for the reset button | `chronometer-reset` |

The reset button is automatically hidden when its text is empty and its icon is disabled or unavailable.

### Controls

| Setting | Description | Default |
|---|---|---|
| Show button icon | Display the reset button icon | Enabled |
| Show timer value | Display the remaining time | Enabled |
| Show percentage | Display the countdown percentage instead of the remaining time | Disabled |
| Allow pause | Enable pause and resume controls | Enabled |

## Usage

1. Add the widget to your desktop or panel.
2. Open its settings and choose the countdown duration and appearance.
3. Let the countdown run.
4. Use the pause button to temporarily stop the countdown.
5. Press the pause button again to resume.
6. Click **Reset** to restart the countdown using the configured duration.

### Expanded representation

The expanded representation displays a horizontal progress bar and the available timer controls.

When the reset button is visible, clicking the progress bar does not trigger a reset. Use the reset button instead.

When the reset button is hidden, clicking the progress bar resets the countdown.

### Compact representation

The compact representation displays a circular progress indicator.

The center of the circle displays either the remaining time or the countdown percentage, depending on the configuration. The text can also be hidden.

When the reset button is visible, clicking the circle opens the expanded representation, where the timer controls are available.

When the reset button is hidden, clicking the circle directly resets the countdown.

### Timer expiration

When the timer reaches zero:

- The progress indicator changes to the configured expiration color.
- The progress indicator starts blinking.
- A desktop notification is sent if notifications are enabled.

The blinking animation stops and the indicator returns to full opacity when the timer is reset.

### Timer persistence

The widget stores its timer state in Plasma's configuration.

When Plasma restarts, the widget restores the previous state:

- **Running:** resumes the countdown using its original deadline.
- **Paused:** restores the remaining time without starting the countdown.
- **Expired:** remains expired without sending the notification again.

If an expired timer has been inactive for more than twice its configured duration, the widget automatically starts a fresh countdown when its state is restored.

This behavior helps prevent an old expired timer from remaining visible indefinitely after a long period of inactivity.

Changing the configured countdown duration resets the timer and starts a new countdown, including when the timer is paused.

## Translations

The widget uses gettext for translations.

Currently available languages:

- English (default).
- Italian.

Translation files are stored in the `translate/` directory.

To update translation catalogs and compile the available translations, run:

```bash
./translate/update.sh
./translate/build.sh
```

The installer automatically builds translations before installing the widget.

## Development

To launch the widget in KDE's standalone Plasmoid Viewer, run:

```bash
./dev.sh
```

This script runs:

```bash
plasmoidviewer -a .
```

### Refresh an installed copy

After making changes, run:

```bash
./refresh.sh
```

This removes and reinstalls the package, then restarts the user Plasma shell.

The refresh process is equivalent to:

```bash
./uninstall.sh
./install.sh
systemctl --user restart plasma-plasmashell
```

**Note:** restarting Plasma can briefly disrupt the desktop panel and widgets. Save any work in progress before running this script.

### Install and uninstall manually

Install:

```bash
./install.sh
```

Uninstall:

```bash
./uninstall.sh
```

The uninstall script reads the package ID from `metadata.json` and removes it using `kpackagetool6`. It requires `jq`.

## Project structure

```text
.
├── contents/
│   ├── config/
│   │   ├── config.qml
│   │   └── main.xml
│   └── ui/
│       ├── configGeneral.qml
│       ├── configAppearance.qml
│       ├── configControls.qml
│       └── main.qml
├── translate/
│   ├── build.sh
│   ├── update.sh
│   └── it.po
├── dev.sh
├── install.sh
├── refresh.sh
├── uninstall.sh
├── LICENSE
├── metadata.json
└── README.md
```

## How it works

The widget is implemented in QML using Qt Quick and KDE Plasma components.

- `contents/ui/main.qml` contains the countdown logic, progress indicators, expiration animation, compact representation, pause/resume controls, reset action, and notification trigger.
- `contents/ui/configGeneral.qml` defines the general settings page.
- `contents/ui/configAppearance.qml` defines appearance settings.
- `contents/ui/configControls.qml` defines display and control options.
- `contents/config/main.xml` declares persistent configuration options and their defaults.
- `contents/config/config.qml` registers the configuration pages.
- `metadata.json` contains the Plasma package metadata.
- `translate/` contains gettext translation catalogs and build scripts.
- `dev.sh`, `install.sh`, `uninstall.sh`, and `refresh.sh` provide development and package-management helpers.

The countdown uses an absolute deadline timestamp rather than decrementing a counter every second. This allows the widget to calculate the correct remaining time after Plasma restarts.

Paused timers store their remaining duration separately, allowing them to be restored without restarting the countdown.

Expired timers store their expiration timestamp, which is used to determine whether a fresh countdown should be started after a long period of inactivity.

The progress indicators are rendered using the current remaining time, ensuring that their visual state is restored correctly even when the timer is paused.

Desktop notifications are triggered through Plasma 6's `org.kde.plasma.plasma5support` data source and its `executable` engine, which invokes `notify-send`.

## Troubleshooting

### The notification does not appear

Check that `notify-send` is installed and that desktop notifications are working:

```bash
command -v notify-send
notify-send "Countdown Timer Bar test" "Notifications are working."
```

Also check that **Expiration notification** is enabled in the widget settings.

### The widget does not load or changes are not visible

Run the development version with:

```bash
./dev.sh
```

Inspect any QML errors printed in the terminal.

If you use `./refresh.sh`, remember that it restarts the Plasma shell.

### The uninstall script fails

Make sure `jq` is installed and run the script from the repository directory.

### The timer does not restore correctly

The timer state is stored in Plasma's applet configuration. Check that the widget's configuration has not been manually modified or corrupted.

## Contributing

Issues, ideas, and pull requests are welcome.

If you adapt this widget or reuse parts of its code, please check the project's license before distributing your changes.

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for details.
