import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root

    // Configurazioni del Timer
    property int totalSeconds: plasmoid.configuration.totalSeconds
    property string tooltipString: plasmoid.configuration.tooltipString
    property string progressBarColor: plasmoid.configuration.progressBarColor
    property string progressBarExpiredColor: plasmoid.configuration.progressBarExpiredColor
    property string buttonText: plasmoid.configuration.buttonText
    property string buttonIcon: plasmoid.configuration.buttonIcon

    property int currentSeconds: totalSeconds
    property bool isRunning: true

    // Se un'impostazione cambia mentre il plasmoide è attivo, aggiorniamo il timer
    Connections {
        target: plasmoid.configuration
        function onTotalSecondsChanged() {
            root.resetTimer()
        }
    }

    // Logica del Timer
    Timer {
        id: countdownTimer
        interval: 1000 // 1 secondo
        repeat: true
        running: root.isRunning
        onTriggered: {
            if (root.currentSeconds > 0) {
                root.currentSeconds -= 1
            } else {
                root.isRunning = false
            }
        }
    }

    // Funzione di Reset
    function resetTimer() {
        root.currentSeconds = root.totalSeconds
        root.isRunning = true
    }

    function formatTime(totalSeconds) {
        let m = Math.floor(totalSeconds / 60);
        let s = totalSeconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    // Layout preferito (widget sul desktop o pannello espanso)
    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        // Spaziatura standard di Plasma
        spacing: Kirigami.Units.smallSpacing
        
        // Assicura che il widget abbia una dimensione minima sensata
        Layout.minimumWidth: 300
        Layout.minimumHeight: 50

        PlasmaComponents.ProgressBar {
            id: progressBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            
            from: 0
            to: root.totalSeconds
            // Se il tempo è 0, forziamo il valore al massimo per vedere la barra piena
            value: root.currentSeconds === 0 ? root.totalSeconds : root.currentSeconds

            contentItem: Rectangle {
                id: barRect
                width: parent.visualPosition * parent.width
                height: parent.height
                radius: 2 
                
                // Colore condizionale: se non è a zero usa il blu, 
                // se è a zero il colore viene gestito dall'animazione
                color: root.currentSeconds > 0 ? root.progressBarColor : root.progressBarExpiredColor

                opacity: root.currentSeconds > 0 ? 1.0 : undefined

                // Animazione di lampeggio (opacità)
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

        PlasmaComponents.Button {
            text: root.buttonText
            icon.name: root.buttonIcon // Icona di sistema
            Layout.alignment: Qt.AlignVCenter
            onClicked: root.resetTimer()
        }
    }
    
    // Rappresentazione compatta (se minimizzato nel pannello)
    compactRepresentation: PlasmaComponents.Label {
        text: formatTime(root.currentSeconds)
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