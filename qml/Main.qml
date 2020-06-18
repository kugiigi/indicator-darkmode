import QtQuick 2.9
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3
import Qt.labs.settings 1.0
import Indicator 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'indicator-darkmode'
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)
    
    Settings {
        id: settings
    
        property bool autoDarkMode: false
        property string startTime: "19:00"
        property string endTime: "06:00"
        property int checkInterval: 15
    }

    Page {
        header: PageHeader {
            id: header
            title: i18n.tr("Suru Dark mode Indicator")
        }

        Flickable {
            id: flickable
            
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: installColumn.top
                bottomMargin: units.gu(2)
            }

            clip: true
            contentHeight: contentColumn.height + units.gu(4)

            ColumnLayout {
                id: contentColumn
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: units.gu(2)
                }
                spacing: units.gu(1)
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr("What is this?")
                    font.bold: true
                    textSize: Label.Large
                    elide: Text.ElideRight
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr("This is a proof of concept for an indicator to switch between Ambiance and Suru Dark theme.")
                    wrapMode: Text.Wrap
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr("What does it exactly do?")
                    font.bold: true
                    textSize: Label.Large
                    elide: Text.ElideRight
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr('It modifies the theme in the config file "/home/phablet/.config/ubuntu-ui-toolkit/theme.ini"')
                    wrapMode: Text.Wrap
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr("How does it work?")
                    font.bold: true
                    textSize: Label.Large
                    elide: Text.ElideRight
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr('Enabling Dark Mode from the indicator will switch to the theme "Suru Dark". ')
                        + i18n.tr('Disabling it will revert back to "Ambiance". ')
                        + i18n.tr('There is also an option to switch the theme automatically based on the time.')
                    wrapMode: Text.Wrap
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: i18n.tr("Anything else?")
                    font.bold: true
                    textSize: Label.Large
                    elide: Text.ElideRight
                }
                
                Label{
                    Layout.fillWidth: true
                    
                    text: "- " + i18n.tr("The theme change won't take effect on currently open apps until they are restarted. ")
                        + "\n\n- " + i18n.tr("Time accuracy for automatically switching to a theme will be based on the set time interval for checking the time.")
                        + "\n\n- " + i18n.tr("Suru Dark theme support varies across apps. There are apps that just works while some will only have partial support and some won't even respect it.")
                        + "\n\n- " + i18n.tr("Reinstall the indicator and reboot or restart Lomiri whenever an update is installed.")
                    wrapMode: Text.Wrap
                }
            }
        }
        
        ColumnLayout {
            id: installColumn
            
            anchors {
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                bottomMargin: units.gu(2)
            }
            
            spacing: units.gu(1)
            
            Rectangle {
                height: units.gu(0.3)
                color: theme.palette.normal.base
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }
            
            ListItem {
                id: switchAuto
                
                property bool bindValue: settings.autoDarkMode
                property bool switchValue: bindValue

                width: parent.width

                ListItemLayout {
                    id: listItemLayout
                    
                    anchors.centerIn: parent
                    title.text: i18n.tr("Auto switch")
                    subtitle.text: i18n.tr("Automatically switch theme based on time")

                    Switch {
                        id: checkItem
                        SlotsLayout.position: SlotsLayout.Leading

                        //workaround where binding to status gets lost when the checkbox is clicked
                        Component.onCompleted: checkItem.checked = switchAuto.bindValue
                        Connections {
                            target: switchAuto
                            onBindValueChanged: {
                                checkItem.checked = target.bindValue
                            }
                        }
                        onClicked: {
                            switchAuto.switchValue = !switchAuto.bindValue
                        }
                    }
                }
                onClicked: {
                    switchValue = !bindValue
                }
                
                onSwitchValueChanged: {
                    settings.autoDarkMode = switchValue
                }
            }
            
            ListItem {
                id: startTimeListitem
                
                property date date: Date.fromLocaleString(Qt.locale(), settings.startTime, "hh:mm")

                visible: settings.autoDarkMode
                Layout.fillWidth: true
                
                onDateChanged: {
                    settings.startTime = date.toLocaleString(Qt.locale(), "hh:mm")
                }
                
                onClicked: PickerPanel.openDatePicker(startTimeListitem, "date", "Hours|Minutes")
                
                ListItemLayout {
                    anchors.centerIn: parent
                    title.text: i18n.tr("Start time")
                    
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        textSize: Label.Large
                        text: startTimeListitem.date.toLocaleTimeString(Qt.locale(),Locale.ShortFormat)
                        SlotsLayout.position: SlotsLayout.Trailing
                    }
                }
            }
            
            ListItem {
                id: endTimeListitem
                
                property date date: Date.fromLocaleString(Qt.locale(), settings.endTime, "hh:mm")

                visible: settings.autoDarkMode
                Layout.fillWidth: true
                
                onDateChanged: {
                    settings.endTime = date.toLocaleString(Qt.locale(), "hh:mm")
                }
                
                onClicked: PickerPanel.openDatePicker(endTimeListitem, "date", "Hours|Minutes")
                
                ListItemLayout {
                    title.text: i18n.tr("End time")
                    
                    Label {
                        textSize: Label.Large
                        text: endTimeListitem.date.toLocaleTimeString(Qt.locale(),Locale.ShortFormat)
                        SlotsLayout.position: SlotsLayout.Trailing
                    }
                }
            }

            
            ListItem {
                id: timeIntervalListItem

                visible: settings.autoDarkMode
                height: Math.max(implicitHeight, timeLItemLayout.height)
                Layout.fillWidth: true
                divider.visible: false
                
                ListItemLayout {
                    id: timeLItemLayout
                    
                    anchors.centerIn: parent
                    title.text: i18n.tr("Time check interval (minutes)")
                    summary.text: i18n.tr("This determines how often the indicator will check the time and if there's a need to toggle the theme.")
                    summary.wrapMode: Text.WordWrap 

                    TextField {
                        id: checkTimeInterval
                        
                        width: units.gu(7)
                        hasClearButton: false

                        validator: IntValidator {
                            bottom: 1
                            top: 60
                        }
                        horizontalAlignment: TextInput.AlignHCenter
                        inputMethodHints: Qt.ImhDigitsOnly
                        SlotsLayout.position: SlotsLayout.Trailing

                        Component.onCompleted: {
                            if (settings.checkInterval) {
                                text = settings.checkInterval;
                            } else {
                                text = '15';
                            }
                        }

                        onTextChanged: {
                            settings.checkInterval = text ? text : '15';
                        }
                    }
                }
            }
            
            Label {
                text: i18n.tr("Warning: The smaller the value, the higher the impact to battery. This takes effect even when auto-switching is disabled.")
                color: theme.palette.normal.negative
                wrapMode: Text.Wrap
                textSize: Label.Small
                
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                Layout.leftMargin: units.gu(2)
            }
            

            Button {
                id: installButton
                
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                text: !Indicator.isInstalled ? i18n.tr("Install Indicator") : i18n.tr("Uninstall Indicator")
                onClicked: {
                    if (Indicator.isInstalled) {
                        Indicator.uninstall();
                    } else {
                        Indicator.install();
                    }
                }
                color: !Indicator.isInstalled ? UbuntuColors.green : UbuntuColors.red
            }
            
            Label {
                id: message

                text: i18n.tr("Uninstall the indicator here before uninstalling the app!") + "\n"
                horizontalAlignment: Text.AlignHCenter
                color: UbuntuColors.red
                
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }

    Connections {
        target: Indicator

        onInstalled: {
            if (success) {
                message.text = i18n.tr("Successfully installed!") + "\n" + i18n.tr("Please reboot or restart Lomiri/Unity8");
                message.color = UbuntuColors.green;
            }
            else {
                message.text = i18n.tr("Failed to install");
                message.color = UbuntuColors.red;
            }
        }

        onUninstalled: {
            if (success) {
                message.text = i18n.tr("Successfully uninstalled!") + "\n" + i18n.tr("Please reboot or restart Lomiri/Unity8");
                message.color = UbuntuColors.green;
            }
            else {
                message.text = i18n.tr("Failed to uninstall");
                message.color = UbuntuColors.red;
            }
        }
    }
}
