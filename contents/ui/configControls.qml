import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami 2.0 as Kirigami

Item {
    Component.onCompleted: {
        console.log("CONFIG LOADED: CONTROLS")
    }

    id: page

    property alias cfg_buttonText: buttonText.text
    property alias cfg_buttonIcon: buttonIcon.text
    property alias cfg_showButtonIcon: showButtonIcon.checked
    property alias cfg_allowPause: allowPause.checked
    property alias cfg_expireCommand: expireCommand.text

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

        TextArea {
            id: expireCommand

            Kirigami.FormData.label: i18n("Command on expiration:")

            Layout.fillWidth: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 4

            placeholderText: i18n("Leave empty to do nothing")
            wrapMode: TextEdit.Wrap
        }
    }
}
