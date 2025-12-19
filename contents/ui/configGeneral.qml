import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents

Kirigami.FormLayout {
    id: page

    // I nomi degli ID devono seguire il pattern: cfg_ + nome_proprietà_nel_main_xml
    property alias cfg_totalSeconds: totalSeconds.value
    property alias cfg_tooltipString: tooltipString.text
    property alias cfg_progressBarColor: progressBarColor.text
    property alias cfg_progressBarExpiredColor: progressBarExpiredColor.text
    property alias cfg_buttonText: buttonText.text
    property alias cfg_buttonIcon: buttonIcon.text

    PlasmaComponents.Label {
        Kirigami.FormData.label: "Impostazioni Timer"
        Kirigami.FormData.isSection: true
    }

    SpinBox {
        id: totalSeconds
        Kirigami.FormData.label: "Secondi totali:"
        from: 1
        to: 86400 // 24 ore
        stepSize: 1
    }

    TextField {
        id: tooltipString
        Kirigami.FormData.label: "Messaggio finale:"
        placeholderText: "Es: TEMPO SCADUTO!"
    }

    TextField {
        id: progressBarColor
        Kirigami.FormData.label: "Colore barra (HEX):"
    }

    TextField {
        id: progressBarExpiredColor
        Kirigami.FormData.label: "Colore scaduto (HEX):"
    }

    TextField {
        id: buttonText
        Kirigami.FormData.label: "Testo pulsante:"
    }

    TextField {
        id: buttonIcon
        Kirigami.FormData.label: "Nome icona KDE:"
    }
}