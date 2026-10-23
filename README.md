# Countdown Timer Bar

A lightweight KDE Plasma 6 widget that displays a countdown as a
horizontal progress bar. The bar gradually empties as time passes and
starts blinking red when the countdown expires.

When the timer reaches zero, the widget can also send a desktop
notification using `notify-send`.

## Features

-   **Visual countdown:** a progress bar that decreases as the timer
    runs.
-   **Expiration indicator:** the bar turns to the configured expiration
    color and blinks when time runs out.
-   **Desktop notification:** optionally sends a notification when the
    countdown expires.
-   **Compact panel display:** shows the remaining time as `MM:SS` when
    the widget is displayed in its compact form.
-   **Configurable appearance and behavior:**
    -   Countdown duration, from 1 second to 24 hours.
    -   Expiration tooltip/message.
    -   Normal and expired bar colors.
    -   Reset button text and KDE icon.
    -   Enable or disable expiration notifications.
-   **Reset button:** restarts the countdown using the configured
    duration.

## Requirements

-   KDE Plasma 6
-   `kpackagetool6` (normally provided by KDE Plasma development/runtime
    packages)
-   `plasmoidviewer` to run the widget during development
-   `notify-send` for desktop notifications
-   `jq` for the provided uninstall script

On Arch Linux, these tools are commonly available through the
distribution's KDE Plasma and `libnotify` packages. Package names can
vary by distribution.

## Installation

Clone or download this repository, then run the installer from the
project directory:

``` bash
git clone https://github.com/<your-username>/kde-countdown-timer-bar.git
cd kde-countdown-timer-bar
./install.sh
```

Replace `<your-username>` and the repository name with the actual GitHub
repository details.

The installer runs:

``` bash
kpackagetool6 --type Plasma/Applet --install .
```

After installation, add **Countdown timer bar** to your desktop or panel
using Plasma's normal widget-adding interface.

If the widget is already installed and Plasma does not show the updated
version, you can use the refresh script described below. It restarts the
Plasma shell, so open widgets and panels may briefly disappear and
reappear.

## Configuration

Open the widget's configuration dialog to customize its behavior.

  -----------------------------------------------------------------------
  Setting                 Description             Default
  ----------------------- ----------------------- -----------------------
  Total seconds           Countdown duration,     3,600 seconds (1 hour)
                          from 1 to 86,400        
                          seconds                 

  Final message           Message shown in the    `TEMPO SCADUTO!`
                          tooltip when the timer  
                          expires; also used as   
                          the notification body   

  Bar color               Color of the bar while  `#00a6f4`
                          the countdown is        
                          running, in hexadecimal 
                          format                  

  Expired bar color       Color used after the    `#ff0000`
                          countdown expires, in   
                          hexadecimal format      

  Button text             Label on the reset      `Reset`
                          button                  

  Button icon             KDE/System icon name    `chronometer-reset`
                          for the reset button    

  Expiration notification Enable or disable a     Enabled
                          desktop notification    
                          when the countdown      
                          expires                 
  -----------------------------------------------------------------------

The notification title is currently **Countdown terminato**. The
notification body uses the configured final message.

## Usage

1.  Add the widget to your desktop or panel.
2.  Open its settings and choose the countdown duration and appearance.
3.  Let the countdown run.
4.  When the timer reaches zero, the bar blinks in the expiration color
    and, if enabled, a desktop notification is sent.
5.  Click **Reset** to start the countdown again.

The compact representation displays the remaining time as `MM:SS`. The
full representation displays the progress bar and reset button.

## Development

To launch the widget in KDE's standalone Plasmoid Viewer, run:

``` bash
./dev.sh
```

This script runs `plasmoidviewer -a .` from the project directory.

### Refresh an installed copy

After making changes, run:

``` bash
./refresh.sh
```

This removes and reinstalls the package, then restarts the user Plasma
shell:

``` bash
./uninstall.sh
./install.sh
systemctl --user restart plasma-plasmashell
```

**Note:** restarting Plasma can briefly disrupt the desktop panel and
widgets. Save any work in progress before running this script.

### Install and uninstall manually

Install:

``` bash
./install.sh
```

Uninstall:

``` bash
./uninstall.sh
```

The uninstall script reads the package ID from `metadata.json` and
removes it with `kpackagetool6`. It uses `jq` to read the JSON file.

## How it works

The widget is implemented in QML using Qt Quick and KDE Plasma
components.

-   `contents/ui/main.qml` contains the countdown, progress bar,
    blinking expiration animation, compact representation, reset action,
    and notification trigger.
-   `contents/ui/configGeneral.qml` defines the settings page.
-   `contents/config/main.xml` declares persistent configuration options
    and their defaults.
-   `contents/config/config.qml` registers the configuration page.
-   `metadata.json` contains the Plasma package metadata.
-   `dev.sh`, `install.sh`, `uninstall.sh`, and `refresh.sh` provide
    development and package-management helpers.

The notification is triggered once when the countdown transitions to
zero. It is sent through `notify-send`, invoked using Plasma 6's
`org.kde.plasma.plasma5support` data source and its `executable` engine.

## Troubleshooting

### The notification does not appear

Check that `notify-send` is installed and that desktop notifications are
working:

``` bash
command -v notify-send
notify-send "Countdown Timer Bar test" "Notifications are working."
```

Also check that **Expiration notification** is enabled in the widget
settings.

### The widget does not load or changes are not visible

Run the development version with `./dev.sh` and inspect any QML errors
printed in the terminal. If you use `./refresh.sh`, remember that it
restarts the Plasma shell.

### The uninstall script fails

Make sure `jq` is installed and run the script from the repository
directory.

## Contributing

Issues, ideas, and pull requests are welcome. If you adapt this widget
or reuse parts of its code, please check the project's license before
distributing your changes.

## License

See [`LICENSE`](LICENSE) for the license terms.
