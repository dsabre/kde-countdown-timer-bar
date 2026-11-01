import QtQuick
import QtQuick.Controls
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: page

    // Le property alias cfg_ rimangono qui
    property alias cfg_buttonText: buttonText.text
    property alias cfg_buttonIcon: buttonIcon.text
    property alias cfg_showButtonIcon: showButtonIcon.checked
    property alias cfg_allowPause: allowPause.checked

    Kirigami.FormLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        TextField {
            id: buttonText
            Kirigami.FormData.label: i18n("Button text:")
        }

        TextField {
            id: buttonIcon
            Kirigami.FormData.label: i18n("Button icon name:")
        }

        CheckBox {
            id: showButtonIcon
            text: i18n("Display button icon")
        }

        CheckBox {
            id: allowPause
            text: i18n("Allow timer pause")
        }
    }
}
