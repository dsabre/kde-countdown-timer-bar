import QtQuick
import QtQuick.Controls
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: page

    // Le property alias cfg_ rimangono qui
    property alias cfg_totalSeconds: totalSeconds.value
    property alias cfg_tooltipString: tooltipString.text
    property alias cfg_notifyOnExpire: notifyOnExpire.checked

    Kirigami.FormLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        SpinBox {
            id: totalSeconds
            Kirigami.FormData.label: i18n("Duration (seconds):")
            from: 1
            to: 86400
            stepSize: 1
        }

        TextField {
            id: tooltipString
            Kirigami.FormData.label: i18n("Expiration message:")
            placeholderText: i18n("TIME'S UP!")
        }

        CheckBox {
            id: notifyOnExpire
            text: i18n("Notify when the timer expires")
        }
    }
}
