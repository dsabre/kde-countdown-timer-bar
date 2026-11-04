import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root

    // Timer configuration
    property int totalSeconds: plasmoid.configuration.totalSeconds
    property string tooltipString: plasmoid.configuration.tooltipString
    property string progressBarColor: plasmoid.configuration.progressBarColor
    property string progressBarExpiredColor: plasmoid.configuration.progressBarExpiredColor
    property string buttonText: plasmoid.configuration.buttonText
    property string buttonIcon: plasmoid.configuration.buttonIcon
    property string expireCommand: plasmoid.configuration.expireCommand
    property bool showButtonIcon: plasmoid.configuration.showButtonIcon
    property bool showTimerValue: plasmoid.configuration.showTimerValue
    property bool showPercentage: plasmoid.configuration.showPercentage
    property bool allowPause: plasmoid.configuration.allowPause

    // Persistent timer state
    property string timerState: plasmoid.configuration.timerState
    property double deadline: plasmoid.configuration.deadline
    property int pausedRemaining: plasmoid.configuration.pausedRemaining
    property double expiredAt: plasmoid.configuration.expiredAt

    // Display state
    property int currentSeconds: totalSeconds

    readonly property bool isPaused: root.timerState === "paused"
    readonly property bool isRunning: root.timerState === "running"

    readonly property bool showResetButton: root.buttonText.trim().length > 0 || (root.showButtonIcon && root.buttonIcon.trim().length > 0)

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
        const now = Date.now()
        const deadline = Number(root.deadline)
        const remaining = Number(root.pausedRemaining)
        const expiredAt = Number(root.expiredAt)
        const duration = Math.max(0, root.totalSeconds)

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

                // Reset if the timer expired more than twice its duration ago.
                if (
                    duration > 0 &&
                    deadline <= now &&
                    now - deadline > duration * 2000
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
                    remaining > duration
                ) {
                    root.resetTimer()
                    return
                }

                // A paused timer must not have an active deadline.
                plasmoid.configuration.deadline = 0
                root.currentSeconds = remaining
                break

            case "expired":
                // Reset if the timer has been expired for too long.
                if (
                    duration > 0 &&
                    Number.isFinite(expiredAt) &&
                    expiredAt > 0 &&
                    now - expiredAt > duration * 2000
                ) {
                    root.resetTimer()
                    return
                }

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
            root.expireTimer()
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

        plasmoid.configuration.expiredAt = 0

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
        plasmoid.configuration.expiredAt = 0
    }

    function executeExpireCommand() {
        const command = root.expireCommand.trim()

        if (command.length === 0) {
            return
        }

        executable.exec(command)
    }

    // Expire countdown
    function expireTimer() {
        plasmoid.configuration.timerState = "expired"
        plasmoid.configuration.deadline = 0
        plasmoid.configuration.pausedRemaining = 0
        plasmoid.configuration.expiredAt = Date.now()

        root.currentSeconds = 0

        root.executeExpireCommand()
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
    preferredRepresentation: plasmoid.formFactor === PlasmaCore.Types.Vertical
        ? compactRepresentation
        : fullRepresentation

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
            value: root.currentSeconds === 0
                ? root.totalSeconds
                : root.currentSeconds

            contentItem: Item {
                Rectangle {
                    width: root.currentSeconds === 0
                        ? parent.width
                        : root.totalSeconds > 0
                            ? parent.width * root.currentSeconds / root.totalSeconds
                            : 0

                    height: parent.height
                    radius: 2
                    anchors.left: parent.left

                    color: root.currentSeconds > 0
                    ? root.progressBarColor
                    : root.progressBarExpiredColor

                    opacity: 1.0

                    SequentialAnimation on opacity {
                        running: root.currentSeconds === 0
                        loops: Animation.Infinite

                        PropertyAnimation {
                            from: 1.0
                            to: 0.2
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }

                        PropertyAnimation {
                            from: 0.2
                            to: 1.0
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            PlasmaComponents.ToolTip {
                text: root.currentSeconds === 0
                    ? root.tooltipString
                    : root.formatTime(root.currentSeconds)

                visible: root.currentSeconds === 0
                    ? root.tooltipString.trim().length > 0
                    : parent.hovered
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
            visible: root.showResetButton
            text: root.buttonText
            icon.name: root.showButtonIcon ? root.buttonIcon : ""
            Layout.alignment: Qt.AlignVCenter
            onClicked: root.resetTimer()
        }

        MouseArea {
            anchors.fill: parent
            enabled: !root.showResetButton

            onClicked: root.resetTimer()
        }
    }

    // Compact representation (when minimized in the panel)

    compactRepresentation: Item {
        id: compactRoot

        implicitWidth: 42
        implicitHeight: 42

        property real progress: root.totalSeconds > 0
        ? Math.max(0, Math.min(1, root.currentSeconds / root.totalSeconds))
        : 0

        opacity: 1.0

        Canvas {
            id: ring

            anchors.fill: parent
            anchors.margins: 2

            property real progress: compactRoot.progress

            property color ringColor: root.currentSeconds > 0
            ? root.progressBarColor
            : root.progressBarExpiredColor

            onProgressChanged: requestPaint()
            onRingColorChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                const centerX = width / 2
                const centerY = height / 2
                const lineWidth = 3.5
                const radius = Math.min(width, height) / 2 - lineWidth / 2

                ctx.clearRect(0, 0, width, height)

                // Background ring
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                ctx.strokeStyle = Qt.rgba(
                    Kirigami.Theme.textColor.r,
                    Kirigami.Theme.textColor.g,
                    Kirigami.Theme.textColor.b,
                    0.2
                )
                ctx.lineWidth = lineWidth
                ctx.stroke()

                // Progress ring
                if (progress > 0 || root.currentSeconds === 0) {
                    const startAngle = -Math.PI / 2
                    const endAngle = root.currentSeconds === 0
                    ? startAngle + Math.PI * 2
                    : startAngle + Math.PI * 2 * progress

                    ctx.beginPath()
                    ctx.arc(
                        centerX,
                        centerY,
                        radius,
                        startAngle,
                        endAngle,
                        false
                    )
                    ctx.strokeStyle = ringColor
                    ctx.lineWidth = lineWidth
                    ctx.lineCap = "round"
                    ctx.stroke()
                }
            }
        }

        PlasmaComponents.Label {
            anchors.centerIn: parent

            visible: root.showTimerValue

            text: root.showPercentage
            ? root.formatPercentage()
            : root.formatTime(root.currentSeconds)

            font.pixelSize: 11
            font.bold: true
            fontSizeMode: Text.Fit
            minimumPixelSize: 6

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        SequentialAnimation {
            running: root.currentSeconds === 0
            loops: Animation.Infinite

            PropertyAnimation {
                target: compactRoot
                property: "opacity"
                from: 1.0
                to: 0.2
                duration: 500
                easing.type: Easing.InOutQuad
            }

            PropertyAnimation {
                target: compactRoot
                property: "opacity"
                from: 0.2
                to: 1.0
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Connections {
            target: root

            function onCurrentSecondsChanged() {
                if (root.currentSeconds > 0) {
                    compactRoot.opacity = 1.0
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.showResetButton) {
                    root.expanded = !root.expanded
                } else {
                    root.resetTimer()
                }
            }
        }
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            root.restoreTimer()
        })
    }
}
