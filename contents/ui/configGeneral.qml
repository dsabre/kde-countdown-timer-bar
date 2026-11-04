import QtQuick
import QtQuick.Controls
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: page

    property alias cfg_totalSeconds: totalSeconds.value
    property alias cfg_tooltipString: tooltipString.text

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

            Kirigami.FormData.label: i18n("Expiration tooltip:")
            placeholderText: i18n("TIME'S UP!")
        }
    }
}
