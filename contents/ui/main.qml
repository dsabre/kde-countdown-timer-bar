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
    property bool isPaused: false
    property bool allowPause: plasmoid.configuration.allowPause

    property int currentSeconds: totalSeconds
    property bool isRunning: true

    // Update the timer if a setting changes while the plasmoid is active
    Connections {
        target: plasmoid.configuration
        function onTotalSecondsChanged() {
            root.resetTimer()
        }
    }

    Connections {
        target: plasmoid.configuration

        function onAllowPauseChanged() {
            if (!root.allowPause) {
                root.isPaused = false
            }
        }
    }

    // Timer logic
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: root.isRunning && !root.isPaused

        onTriggered: {
            if (root.currentSeconds > 0) {
                root.currentSeconds -= 1

                if (root.currentSeconds === 0) {
                    root.isRunning = false
                    root.notifyTimerExpired()
                }
            } else {
                root.isRunning = false
            }
        }
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

    // Reset the timer
    function resetTimer() {
        root.currentSeconds = root.totalSeconds
        root.isPaused = false
        root.isRunning = true
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
                root.isPaused = !root.isPaused
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
}
