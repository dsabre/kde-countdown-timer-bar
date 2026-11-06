import QtQuick
import QtQuick.Controls
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls

Item {
    id: page

    // Le property alias cfg_ rimangono qui
    property alias cfg_progressBarColor: progressBarColor.color
    property alias cfg_progressBarExpiredColor: progressBarExpiredColor.color
    property alias cfg_showTimerValue: showTimerValue.checked
    property alias cfg_showPercentage: showPercentage.checked
    property alias cfg_invertProgressBar: invertProgressBar.checked

    Kirigami.FormLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        KQControls.ColorButton {
            id: progressBarColor
            Kirigami.FormData.label: i18n("Progress bar color:")
        }

        KQControls.ColorButton {
            id: progressBarExpiredColor
            Kirigami.FormData.label: i18n("Expired bar color:")
        }

        CheckBox {
            id: showTimerValue
            Kirigami.FormData.label: i18n("Timer:")
            text: i18n("Show timer value")
        }

        CheckBox {
            id: showPercentage
            text: i18n("Show percentage instead of time")
        }

        CheckBox {
            id: invertProgressBar
            text: i18n("Invert progress bar")
        }
    }
}
