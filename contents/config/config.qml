import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")       // Tab label in the configuration dialog
        icon: "configure"           // Configuration icon
        source: "configGeneral.qml" // Path to the configuration page
    }
}
