import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import org.kde.kcmutils
import org.kde.kirigami as Kirigami

import "../../tools/tools.js" as JS

SimpleKCM {
    property string cfg_terminal: plasmoid.configuration.terminal
    property alias cfg_tmuxSession: tmuxSession.checked
    property alias cfg_idleInhibit: idleInhibit.checked
    property alias cfg_termFont: termFont.checked
    property alias cfg_mngHideFlatpak: mngHideFlatpak.checked
    property alias cfg_mngHideHeaders: mngHideHeaders.checked
    property alias cfg_mngHideHelp: mngHideHelp.checked
    property alias cfg_mngHideNums: mngHideNums.checked
    property alias cfg_fzfOptions: fzfOptions.text

    property string cfg_wrapper: plasmoid.configuration.wrapper
    property alias cfg_archFlags: archFlags.text
    property alias cfg_sudoBin: sudoBin.text
    property alias cfg_rebootSystem: rebootSystem.checked

    property alias cfg_flatpakRemoveUnused: flatpakRemoveUnused.checked
    property string cfg_flatpakFlags: plasmoid.configuration.flatpakFlags

    property alias cfg_widgetConfirmation: widgetConfirmation.checked
    property alias cfg_restartShell: restartShell.checked
    property alias cfg_restartCommand: restartCommand.text
    property alias cfg_trayEnabledByDefault: trayEnabledByDefault.checked

    property var pkg: plasmoid.configuration.packages
    property var terminals: plasmoid.configuration.terminals
    property alias cfg_preExec: preExec.text
    property alias cfg_postExec: postExec.text

    property int currentTab
    signal tabChanged(currentTab: int)
    onCurrentTabChanged: tabChanged(currentTab)

    header: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                icon.name: "akonadiconsole"
                text: i18n("General")
                checked: currentTab === 0
                onTriggered: currentTab = 0
            },
            Kirigami.Action {
                icon.name: "apdatifier-package"
                text: "Apt (Ishimura)"
                checked: currentTab === 1
                onTriggered: currentTab = 1
            },
            Kirigami.Action {
                icon.name: "apdatifier-flatpak"
                text: "Flatpak"
                checked: currentTab === 2
                onTriggered: currentTab = 2
            },
            Kirigami.Action {
                icon.name: "start-here-kde-plasma-symbolic"
                text: i18n("Widgets")
                checked: currentTab === 3
                onTriggered: currentTab = 3
            }
        ]
    }

    Kirigami.FormLayout {
        id: terminalTab
        visible: currentTab === 0

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Terminal") + ":"

            ComboBox {
                model: terminals
                textRole: "name"
                enabled: terminals

                onCurrentIndexChanged: cfg_terminal = model[currentIndex]["value"]

                Component.onCompleted: {
                    if (terminals) {
                        currentIndex = JS.setIndex(plasmoid.configuration.terminal, terminals);

                        if (!plasmoid.configuration.terminal) {
                            plasmoid.configuration.terminal = model[0]["value"];
                        }
                    }
                }
            }

            Kirigami.UrlButton {
                url: "https://github.com/exequtic/apdatifier#supported-terminals"
                text: i18n("Not installed")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: Kirigami.Theme.neutralTextColor
                visible: !terminals
            }
        }

        RowLayout {
            CheckBox {
                id: termFont
                text: i18n("Use NerdFont icons")
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("If your terminal utilizes any <b>Nerd Font</b>, icons from that font will be used.")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            CheckBox {
                id: tmuxSession
                text: i18n("tmux session")
                enabled: pkg.tmux
            }
        }

        RowLayout {
            CheckBox {
                id: idleInhibit
                text: i18n("Idle Inhibit")
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Disables automatic sleep and screen lock while upgrading.")
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Pre/post upgrade scripts")
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Pre-exec") + ":"

            TextField {
                id: preExec
                placeholderText: i18n("Command or script path")
                placeholderTextColor: "grey"
            }

            Button {
                icon.name: "document-open"
                onClicked: fileDialogPreExec.open()
            }

            FileDialog {
                id: fileDialogPreExec
                fileMode: FileDialog.OpenFile
                onAccepted: preExec.text = selectedFile.toString().substring(7)
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Running your command or script BEFORE the upgrade.<br>For example, you can specify your command to update the mirrorlist if you have unofficial repositories.")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Post-exec") + ":"

            TextField {
                id: postExec
                placeholderText: i18n("Command or script path")
                placeholderTextColor: "grey"
            }

            Button {
                icon.name: "document-open"
                onClicked: fileDialogPostExec.open()
            }

            FileDialog {
                id: fileDialogPostExec
                fileMode: FileDialog.OpenFile
                onAccepted: postExec.text = selectedFile.toString().substring(7)
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Running your command or script AFTER the upgrade.<br>For example, you can specify your command to upgrade something else.")
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Management")
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: mngHideFlatpak
            text: i18n("Without Flatpak options")
        }
        CheckBox {
            id: mngHideHeaders
            text: i18n("Hide headers")
        }
        CheckBox {
            id: mngHideHelp
            text: i18n("Hide help")
        }
        CheckBox {
            id: mngHideNums
            text: i18n("Hide option numbers")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fzf options") + ":"

            TextField {
                id: fzfOptions
                placeholderText: "--style full --layout default"
                placeholderTextColor: "grey"
                Layout.preferredWidth: 250
                onTextChanged: {
                    var sanitized = fzfOptions.text.replace(/["'\\$`\n\r]/g, "");
                    if (sanitized !== fzfOptions.text)
                        fzfOptions.text = sanitized;
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("Override default fzf options.<br>See <b>fzf --help</b> for available options.")
            }
        }
    }

    Kirigami.FormLayout {
        id: archTab
        visible: currentTab === 1

        Item {
            Kirigami.FormData.isSection: true
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Upgrade options") + ":"

            Label {
                text: cfg_sudoBin + " " + "apt update && " + cfg_sudoBin + " apt upgrade"
            }

            TextField {
                id: archFlags
                onTextChanged: {
                    var allow = /^[a-z0-9\- ]*$/;
                    if (!allow.test(archFlags.text))
                        archFlags.text = archFlags.text.replace(/[^a-z0-9\- ]/g, "");
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: "sudobin:"
            spacing: 0
            enabled: pkg.apt

            TextField {
                id: sudoBin
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Reboot system") + ":"

            CheckBox {
                id: rebootSystem
                text: i18n("Suggest after upgrading")
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("This option suggests restarting the system after upgrading critical packages.<br><br><b>Note that not all critical packages require a full system restart; some may only need a session restart or no action at all, such as when an updated package is not currently running (e.g., an alternative kernel) or not in use (e.g., an alternative driver).</b>")
            }
        }
    }

    Kirigami.FormLayout {
        id: flatpakTab
        visible: currentTab === 2

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Uninstall unused") + ":"

            CheckBox {
                id: flatpakRemoveUnused
                text: i18n("Enable")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        ButtonGroup {
            id: flatpakFlags
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Upgrade options") + ":"

            RadioButton {
                ButtonGroup.group: flatpakFlags
                text: i18n("Normal")
                checked: plasmoid.configuration.flatpakFlags === ""
                onCheckedChanged: {
                    if (checked)
                        cfg_flatpakFlags = "";
                }
            }
        }

        RadioButton {
            ButtonGroup.group: flatpakFlags
            text: i18n("Normal, skip questions")
            checked: plasmoid.configuration.flatpakFlags === "--assumeyes"
            onCheckedChanged: {
                if (checked)
                    cfg_flatpakFlags = "--assumeyes";
            }
        }

        RadioButton {
            ButtonGroup.group: flatpakFlags
            text: i18n("Non interactive, skip questions")
            checked: plasmoid.configuration.flatpakFlags === "--noninteractive"
            onCheckedChanged: {
                if (checked)
                    cfg_flatpakFlags = "--noninteractive";
            }
        }

        RadioButton {
            ButtonGroup.group: flatpakFlags
            text: i18n("Verbose")
            checked: plasmoid.configuration.flatpakFlags === "--verbose"
            onCheckedChanged: {
                if (checked)
                    cfg_flatpakFlags = "--verbose";
            }
        }
    }

    Kirigami.FormLayout {
        id: widgetsTab
        visible: currentTab === 3

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Upgrade confirmation") + ":"

            CheckBox {
                id: widgetConfirmation
                text: i18n("Enable")
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Restart plasmashell") + ":"

            CheckBox {
                id: restartShell
                text: i18n("Suggest after upgrading")
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n("After upgrading widget, the old version will still remain in memory until you restart plasmashell. To avoid doing this manually, enable this option.")
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Command") + ":"

            TextField {
                id: restartCommand
                enabled: restartShell.checked
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Apdatifier tray icon") + ":"

            CheckBox {
                id: trayEnabledByDefault
                text: i18n("Enabled by default")
            }
        }
    }

    Component.onCompleted: {
        if (tmuxSession.checked && !pkg.tmux)
            tmuxSession.checked = plasmoid.configuration.tmuxSession = false;
    }
}
