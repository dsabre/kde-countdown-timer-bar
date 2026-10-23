import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

Kirigami.FormLayout {
    id: page

    // ID names must follow the pattern: cfg_ + property_name_in_main_xml
    property alias cfg_totalSeconds: totalSeconds.value
    property alias cfg_tooltipString: tooltipString.text
    property alias cfg_progressBarColor: progressBarColor.text
    property alias cfg_progressBarExpiredColor: progressBarExpiredColor.text
    property alias cfg_buttonText: buttonText.text
    property alias cfg_buttonIcon: buttonIcon.text
    property alias cfg_notifyOnExpire: notifyOnExpire.checked

    PlasmaComponents.Label {
        Kirigami.FormData.label: "Countdown Timer Bar Settings"
        Kirigami.FormData.isSection: true
    }

    SpinBox {
        id: totalSeconds
        Kirigami.FormData.label: "Duration (seconds):"
        from: 1
        to: 86400 // 24 hours
        stepSize: 1
    }

    TextField {
        id: tooltipString
        Kirigami.FormData.label: "Expiration message:"
        placeholderText: "e.g. TIME'S UP!"
    }

    TextField {
        id: progressBarColor
        Kirigami.FormData.label: "Progress bar color (HEX):"
    }

    TextField {
        id: progressBarExpiredColor
        Kirigami.FormData.label: "Expired bar color (HEX):"
    }

    TextField {
        id: buttonText
        Kirigami.FormData.label: "Button text:"
    }

    TextField {
        id: buttonIcon
        Kirigami.FormData.label: "KDE icon name:"
    }

    CheckBox {
        id: notifyOnExpire
        Kirigami.FormData.label: "Notifications:"
        text: "Notify when the timer expires"
    }
}
