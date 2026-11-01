import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Timer configuration
    property int totalSeconds: plasmoid.configuration.totalSeconds
    property string tooltipString: plasmoid.configuration.tooltipString
    property string progressBarColor: plasmoid.configuration.progressBarColor
    property string progressBarExpiredColor: plasmoid.configuration.progressBarExpiredColor
    property string buttonText: plasmoid.configuration.buttonText
    property string buttonIcon: plasmoid.configuration.buttonIcon
    property bool notifyOnExpire: plasmoid.configuration.notifyOnExpire
    property bool showButtonIcon: plasmoid.configuration.showButtonIcon
    property bool showTimerValue: plasmoid.configuration.showTimerValue
    property bool showPercentage: plasmoid.configuration.showPercentage
    property bool allowPause: plasmoid.configuration.allowPause

    // Persistent timer state
    property string timerState: plasmoid.configuration.timerState
    property double deadline: plasmoid.configuration.deadline
    property int pausedRemaining: plasmoid.configuration.pausedRemaining

    // Display state
    property int currentSeconds: totalSeconds

    readonly property bool isPaused: root.timerState === "paused"
    readonly property bool isRunning: root.timerState === "running"

    // Update the timer if a setting changes while the plasmoid is active
    Connections {
        target: plasmoid.configuration

        function onTotalSecondsChanged() {
            root.resetTimer()
        }

        function onAllowPauseChanged() {
            if (!root.allowPause && root.isPaused) {
                root.resumeTimer()
            }
        }
    }

    // Timer logic
    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        running: root.isRunning

        onTriggered: root.updateTimer()
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        function exec(command) {
            connectSource(command)
        }

        onNewData: function(source, data) {
            disconnectSource(source)
        }
    }

    // Restore timer state when the plasmoid starts
    function restoreTimer() {
        const deadline = Number(root.deadline)
        const remaining = Number(root.pausedRemaining)

        switch (root.timerState) {
            case "running":
                // A valid running timer must have a valid deadline.
                if (
                    !Number.isFinite(deadline) ||
                    deadline <= 0 ||
                    deadline > 8640000000000000
                ) {
                    root.resetTimer()
                    return
                }

                // Remove stale paused data.
                if (root.pausedRemaining !== 0) {
                    plasmoid.configuration.pausedRemaining = 0
                }

                root.updateTimer()
                break

            case "paused":
                // A valid paused timer must have a positive,
                // integer remaining duration within the configured duration.
                if (
                    !Number.isInteger(remaining) ||
                    remaining <= 0 ||
                    remaining > root.totalSeconds
                ) {
                    root.resetTimer()
                    return
                }

                // A paused timer must not have an active deadline.
                plasmoid.configuration.deadline = 0
                root.currentSeconds = remaining
                break

            case "expired":
                // Normalize expired timer data.
                plasmoid.configuration.deadline = 0
                plasmoid.configuration.pausedRemaining = 0
                root.currentSeconds = 0
                break

            default:
                // Unknown state: restore a fresh timer.
                root.resetTimer()
        }
    }

    // Update remaining time using the actual deadline
    function updateTimer() {
        let remaining = Math.ceil(
            (root.deadline - Date.now()) / 1000
        )

        if (remaining <= 0) {
            root.expireTimer(true)
            return
        }

        root.currentSeconds = remaining
    }

    // Reset countdown
    function resetTimer() {
        let duration = Math.max(0, root.totalSeconds)

        root.currentSeconds = duration

        plasmoid.configuration.timerState = duration > 0
        ? "running"
        : "expired"

        plasmoid.configuration.deadline = duration > 0
        ? Date.now() + duration * 1000
        : 0

        plasmoid.configuration.pausedRemaining = 0

        if (duration === 0) {
            root.currentSeconds = 0
        }
    }

    // Pause countdown
    function pauseTimer() {
        if (!root.isRunning || root.currentSeconds <= 0) {
            return
        }

        // Synchronize before pausing
        root.updateTimer()

        if (!root.isRunning) {
            return
        }

        plasmoid.configuration.pausedRemaining = root.currentSeconds
        plasmoid.configuration.deadline = 0
        plasmoid.configuration.timerState = "paused"
    }

    // Resume countdown
    function resumeTimer() {
        if (!root.isPaused || root.pausedRemaining <= 0) {
            return
        }

        root.currentSeconds = root.pausedRemaining

        plasmoid.configuration.deadline =
        Date.now() + root.pausedRemaining * 1000

        plasmoid.configuration.pausedRemaining = 0
        plasmoid.configuration.timerState = "running"
    }

    // Expire countdown
    function expireTimer(notify) {
        plasmoid.configuration.timerState = "expired"
        plasmoid.configuration.deadline = 0
        plasmoid.configuration.pausedRemaining = 0

        root.currentSeconds = 0

        if (notify) {
            root.notifyTimerExpired()
        }
    }

    function notifyTimerExpired() {
        if (!root.notifyOnExpire) {
            return
        }

        executable.exec(
            "notify-send " +
            "'Countdown timer bar' " +
            "'" + root.tooltipString.replace(/'/g, "'\\''") + "'"
        )
    }

    function formatTime(totalSeconds) {
        let h = Math.floor(totalSeconds / 3600)
        let m = Math.floor((totalSeconds % 3600) / 60)
        let s = totalSeconds % 60

        let mm = m < 10 ? "0" + m : m
        let ss = s < 10 ? "0" + s : s

        if (h > 0) {
            let hh = h < 10 ? "0" + h : h
            return hh + ":" + mm + ":" + ss
        }

        return mm + ":" + ss
    }

    function formatPercentage() {
        if (root.totalSeconds <= 0) {
            return "0%"
        }

        return Math.ceil(
            (root.currentSeconds / root.totalSeconds) * 100
        ) + "%"
    }

    // Preferred layout (widget on the desktop or in an expanded panel)
    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        // Use Plasma's standard spacing
        spacing: Kirigami.Units.smallSpacing

        // Ensure the widget has a sensible minimum size
        Layout.minimumWidth: 300
        Layout.minimumHeight: 50

        PlasmaComponents.ProgressBar {
            id: progressBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            from: 0
            to: root.totalSeconds

            // When the timer reaches zero, force the value to the maximum
            // so the progress bar appears full
            value: root.currentSeconds === 0 ? root.totalSeconds : root.currentSeconds

            contentItem: Rectangle {
                id: barRect
                width: parent.visualPosition * parent.width
                height: parent.height
                radius: 2

                // Conditional color: use blue while the timer is running;
                // when it reaches zero, the animation controls the appearance
                color: root.currentSeconds > 0 ? root.progressBarColor : root.progressBarExpiredColor

                opacity: root.currentSeconds > 0 ? 1.0 : undefined

                // Blinking animation (opacity)
                SequentialAnimation on opacity {
                    running: root.currentSeconds === 0
                    loops: Animation.Infinite
                    PropertyAnimation { from: 1.0; to: 0.2; duration: 500; easing.type: Easing.InOutQuad }
                    PropertyAnimation { from: 0.2; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                }
            }

            PlasmaComponents.ToolTip {
                text: root.currentSeconds === 0 ? root.tooltipString : root.formatTime(root.currentSeconds)
                visible: parent.hovered || root.currentSeconds === 0
            }
        }

        PlasmaComponents.Label {
            visible: root.showTimerValue

            text: root.showPercentage
            ? root.formatPercentage()
            : root.formatTime(root.currentSeconds)

            Layout.alignment: Qt.AlignVCenter
            font.bold: true
        }

        PlasmaComponents.Button {
            visible: root.allowPause

            icon.name: root.isPaused
            ? "media-playback-start"
            : "media-playback-pause"

            enabled: root.currentSeconds > 0

            Layout.alignment: Qt.AlignVCenter

            onClicked: {
                if (root.isPaused) {
                    root.resumeTimer()
                } else {
                    root.pauseTimer()
                }
            }
        }

        PlasmaComponents.Button {
            text: root.buttonText
            icon.name: root.showButtonIcon ? root.buttonIcon : ""
            Layout.alignment: Qt.AlignVCenter
            onClicked: root.resetTimer()
        }
    }

    // Compact representation (when minimized in the panel)
    compactRepresentation: PlasmaComponents.Label {
        text: root.showTimerValue
        ? (root.showPercentage
        ? root.formatPercentage()
        : root.formatTime(root.currentSeconds))
        : ""

        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: root.currentSeconds > 0 ? root.progressBarColor : root.progressBarExpiredColor
        opacity: root.currentSeconds > 0 ? 1.0 : undefined

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }

        SequentialAnimation on opacity {
            running: root.currentSeconds === 0
            loops: Animation.Infinite
            PropertyAnimation { from: 1.0; to: 0.2; duration: 500; easing.type: Easing.InOutQuad }
            PropertyAnimation { from: 0.2; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    Component.onCompleted: {
        root.restoreTimer()
    }
}
