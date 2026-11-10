
# Countdown Timer Bar

A lightweight KDE Plasma 6 widget that displays a configurable countdown as a progress bar.

The widget supports both horizontal and compact circular representations, customizable colors, pause and resume, and user-defined commands when the countdown expires.

## Features

- **Countdown timer**
  - Configurable duration from 1 second to 24 hours.
  - Accurate countdown based on timestamps.
  - Supports `MM:SS` and `HH:MM:SS` time formats.

- **Progress indicator**
  - Horizontal progress bar.
  - Optional inverted progress direction: the bar can either decrease or fill up as time passes.
  - Compact circular progress indicator when displayed in a vertical panel.
  - Customizable progress and expiration colors.

- **Expiration behavior**
  - Blinking animation when the countdown expires.
  - Configurable expiration color.
  - Optional expiration tooltip.
  - Custom shell command executed when the countdown expires.

- **Pause and resume**
  - Optional pause/resume button.
  - Reduced opacity while the timer is paused.
  - Automatically restores normal opacity when resumed or reset.

- **Configurable interface**
  - Show or hide the timer value.
  - Display the remaining percentage instead of the time.
  - Customizable reset button text and icon.
  - Reset button can be hidden.

- **Persistent timer state**
  - Running, paused, and expired states are preserved across Plasma restarts.
  - Remaining time is restored automatically.
  - Expired timers are automatically reset after a sufficiently long period.

- **Translations**
  - Italian translations using gettext.
  - English fallback.

## Requirements

- KDE Plasma 6
- `kpackagetool6` for installing and removing the widget.
- `plasmoidviewer` for development and testing.
- `jq` for the uninstall script.
- Bash for the provided scripts and expiration commands.

The expiration command can use any executable available in the user's environment. Additional utilities such as `notify-send` or `paplay` are optional and only required if used by the configured command.

## Installation

Clone the repository:

```bash
git clone https://github.com/dsabre/kde-countdown-timer-bar.git
cd kde-countdown-timer-bar
```

Run the installer:

```bash
./install.sh
```

The installer builds the translations and installs the Plasma applet using:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

After installation, add **Countdown timer bar** to your desktop or panel using Plasma's widget-adding interface.

### Updating an installed copy

After making changes or pulling updates, run:

```bash
./refresh.sh
```

The refresh script:

1. Uninstalls the current widget.
2. Builds translations and reinstalls the widget.
3. Restarts the user Plasma shell.

**Note:** Restarting Plasma can briefly disrupt the desktop panel and widgets. Save any work in progress before running this script.

### Uninstallation

To remove the widget:

```bash
./uninstall.sh
```

The uninstall script reads the applet ID from `metadata.json` and removes it using `kpackagetool6`.

## Configuration

Open the widget's configuration dialog to customize its behavior.

Settings are organized into three categories.

### General

| Setting | Description | Default |
|---|---|---|
| Duration (seconds) | Countdown duration, from 1 to 86,400 seconds. | `3600` |
| Expiration tooltip | Message displayed when the countdown expires. Leave empty to disable the expiration tooltip. | `TIME'S UP!` |

While the countdown is running, hovering over the progress bar displays the remaining time.

When the countdown expires, the configured tooltip is displayed automatically. If the field is empty, no expiration tooltip is shown.

### Appearance

| Setting | Description | Default |
|---|---|---|
| Progress bar color | Color used while the countdown is running. | `#00a6f4` |
| Expired bar color | Color used when the countdown expires. | `#ff0000` |
| Show timer value | Displays the remaining time alongside the progress indicator. | Enabled |
| Show percentage | Displays the remaining percentage instead of the time. | Disabled |
| Invert progress bar | Reverses the progress direction: the bar fills up instead of emptying. | Disabled |

The inverted progress option also affects the compact circular representation.

### Controls

| Setting | Description | Default |
|---|---|---|
| Button text | Text displayed on the reset button. | `Reset` |
| Button icon name | KDE/System icon name used by the reset button. | `chronometer-reset` |
| Display button icon | Enables or disables the reset button icon. | Configurable |
| Allow timer pause | Enables or disables the pause/resume button. | Configurable |
| Command on expiration | Shell command executed when the countdown expires. | Empty |

#### Reset button

The reset button is displayed when it has either non-empty text or an enabled, non-empty icon.

If both are disabled or empty, the reset button is hidden. The progress bar or compact representation can then be clicked to reset the countdown.

#### Command on expiration

The widget can execute a custom Bash command when the countdown reaches zero.

Leave the field empty to do nothing.

Commands are executed in the current user's session, without requiring root privileges.

Examples:

Send a desktop notification:

```bash
notify-send "Countdown Timer Bar" "Timer expired!"
```

Play a sound:

```bash
paplay /usr/share/sounds/freedesktop/stereo/complete.oga
```

Execute a script:

```bash
/home/user/scripts/timer-finished.sh
```

Use shell command substitution:

```bash
notify-send "Countdown Timer Bar" "Expired at $(date '+%H:%M:%S')"
```

Bash syntax is supported, including command substitution, variables, pipes and redirections.

The command is executed once when the timer transitions to the expired state. No internal desktop notification is generated by the widget.

## Usage

1. Add the widget to your desktop or panel.
2. Open its settings and configure the duration and appearance.
3. Let the countdown run.
4. Use the pause/resume button if needed.
5. When the countdown reaches zero, the progress indicator changes to the expiration color and starts blinking.
6. The configured expiration tooltip is displayed, if present.
7. The configured shell command is executed, if present.
8. Click **Reset** to start a new countdown.

### Representations

**Horizontal representation**

Used on the desktop and in horizontal panels. Displays the progress bar, optional timer value, pause/resume button and reset button.

**Compact circular representation**

Used in vertical panels. Displays a circular progress indicator and the optional timer value.

The compact representation can be clicked to expand the widget or reset the countdown when the reset button is hidden.

### Progress direction

The progress indicator supports two modes:

- **Normal:** starts full and gradually empties.
- **Inverted:** starts empty and gradually fills up.

In both modes, the indicator becomes completely filled when the countdown expires.

### Pause and resume

When paused:

- The countdown stops.
- The remaining time is preserved.
- The progress bar opacity is reduced.
- The timer can be resumed without losing the remaining time.

Resuming restores the normal opacity.

## How it works

The widget is implemented in QML using Qt Quick and KDE Plasma components.

### Timer and persistence

The countdown uses an absolute timestamp rather than decrementing a counter once per second.

The remaining time is recalculated from the deadline, keeping the countdown accurate even if Plasma is temporarily busy.

The following state is persisted:

- `timerState`: current state (`running`, `paused` or `expired`).
- `deadline`: absolute expiration timestamp.
- `pausedRemaining`: remaining seconds when paused.
- `expiredAt`: timestamp of expiration.

When Plasma restarts, the widget restores the previous state automatically.

Expired timers are reset if they have remained expired for more than twice their configured duration.

### Expiration command

The expiration command is executed through Plasma 6's `org.kde.plasma.plasma5support` data source using its executable engine.

The configured command is passed to Bash, allowing shell syntax and command substitution.

The command is executed as the current desktop user.

### Progress animation

The horizontal progress indicator uses a custom QML rectangle to control its width, color and opacity.

When the timer expires, the indicator changes to the expiration color and starts a blinking animation.

When paused, the blinking animation is disabled and the indicator remains at reduced opacity.

## Development

To launch the widget in KDE's standalone Plasmoid Viewer, run:

```bash
./dev.sh
```

This script runs:

```bash
plasmoidviewer -a .
```

The development version can be used to test changes without installing the widget.

### Refresh an installed copy

After making changes, run:

```bash
./refresh.sh
```

This script performs:

```bash
./uninstall.sh
./install.sh
systemctl --user restart plasma-plasmashell
```

### Install and uninstall manually

Install:

```bash
./install.sh
```

Uninstall:

```bash
./uninstall.sh
```

### Translations

Translations are stored in the `translate` directory.

The project uses gettext `.po` files.

Build the translations:

```bash
./translate/build.sh
```

Update the translation template from the source:

```bash
./translate/update.sh
```

The installer automatically builds the translations before installing the applet.

## Project structure

```text
.
├── contents
│   ├── config
│   │   ├── config.qml
│   │   └── main.xml
│   └── ui
│       ├── configGeneral.qml
│       ├── configAppearance.qml
│       ├── configControls.qml
│       └── main.qml
├── translate
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

## Troubleshooting

### The widget does not load

Run the development version:

```bash
./dev.sh
```

Inspect the terminal output for QML errors or missing dependencies.

### Changes are not visible

Run:

```bash
./refresh.sh
```

Remember that this script restarts the Plasma shell.

### The expiration command does not execute

Test the command directly in a terminal first.

Check that Bash is available:

```bash
command -v bash
```

For scripts, verify that the file exists and is executable:

```bash
chmod +x /path/to/script.sh
```

If a command cannot be found when launched by Plasma, try using its absolute path.

### The expiration tooltip does not appear

Check that the **Expiration tooltip** setting is not empty.

An empty value intentionally disables the expiration tooltip.

### The uninstall script fails

Make sure `jq` is installed:

```bash
command -v jq
```

Run the script from the repository directory.

## Contributing

Issues, ideas and pull requests are welcome.

If you adapt this widget or reuse parts of its code, please check the project's license before distributing your changes.

## License

This project is licensed under the MIT License.

See [`LICENSE`](LICENSE) for the full license terms.
