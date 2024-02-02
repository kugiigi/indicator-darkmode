import QtQuick 2.9
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Pickers 1.3
import Qt.labs.settings 1.0
import Indicator 1.0
import io.thp.pyotherside 1.4 //for Python
import Lomiri.Components.Popups 1.3

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'indicator-darkmode'
    automaticOrientation: true
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)
    
    // Change theme in real time when set to follow system theme
    // Only works when the app gets unfocused then focused
    // Possibly ideal so the change won't happen while the user is using the app
    property string previousTheme: Theme.name
    Connections {
        target: Qt.application
        onStateChanged: {
            if (target.state == Qt.ApplicationActive && previousTheme !== theme.name) {
                theme.name = Theme.name
                theme.name = ""
            } else {
                previousTheme = Theme.name
            }
        }
    }

    Settings {
        id: settings

        property bool autoDarkMode: false
        property string startTime: "19:00"
        property string endTime: "06:00"
        property int checkInterval: 15
        property bool logging: false
        property bool alwaysHideIndicatorIcon: false
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
                }
                spacing: units.gu(1)
            
                ListItem {
                    id: expandableListItem

                    Layout.fillWidth: true
                    Layout.preferredHeight: !expansion.expanded ? headerListItem.height : expansion.height
                    expansion.height: headerListItem.height + expandableListLoader.height + units.gu(4)
                    onClicked: expansion.expanded = !expansion.expanded

                    ListItem {
                        id: headerListItem
                        
                        height: expandableHeader.height + divider.height

                        ListItemLayout {
                            id: expandableHeader
                            title.text: i18n.tr("What is this?")
                            title.font.bold: true
                            title.font.pixelSize: units.gu(2)
                            
                            Icon {
                                id: info

                                width: units.gu(3)
                                height: width
                                SlotsLayout.position: SlotsLayout.Leading
                                name: "help"
                                asynchronous: true
                            }

                            Icon {
                                id: arrow

                                width: units.gu(2)
                                height: width
                                SlotsLayout.position: SlotsLayout.Trailing
                                name: "go-down"
                                rotation: expandableListItem.expansion.expanded ? 180 : 0
                                asynchronous: true

                                Behavior on rotation {
                                    LomiriNumberAnimation {}
                                }
                            }
                        }
                    }

                    Loader {
                        id: expandableListLoader
                        
                        asynchronous: true
                        anchors{
                            top: headerListItem.bottom
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }
                        sourceComponent: expandableListItem.expansion.expanded ? expandableListComponent : undefined
                    }

                    Component {
                        id: expandableListComponent
                        ColumnLayout {
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

                                text: i18n.tr('It modifies the theme in the config file "/home/phablet/.config/lomiri-ui-toolkit/theme.ini"')
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
                                    + "\n\n- " + i18n.tr("Impact on battery is still unknown but do let me know if you notice significant reduction of battery.")
                                    + "\n\n- " + i18n.tr("Some devices such as the Pinephone and Meizu MX4 may have less accurate scheduled switching due to their deep sleep behavior.")
                                    + i18n.tr("For these devices, it is advised to use lower interval time and just observe the battery. ")
                                    + i18n.tr("For other devices such as the Nexus 5, it's fine to set the interval to max 60 minutes and it'll still be accurate.")
                                    + "\n\n- " + i18n.tr("Suru Dark theme support varies across apps. There are apps that just works while some will only have partial support and some won't even respect it.")
                                    + "\n\n- " + i18n.tr("Reinstall the indicator and reboot whenever an update is installed.")
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
                
                ListItem {
                    id: sectionLabel

                    Layout.preferredHeight: units.gu(4)
                    divider.visible: true
                    divider.height: units.gu(0.2)
                    highlightColor: "transparent"
                    
                    Layout.fillWidth: true
                    
                    ListItemLayout {
                        padding.top: 0
                        padding.bottom: units.gu(1)
                        anchors.centerIn: parent
                        title.text: i18n.tr("Schedule Settings")
                        title.font.weight: Font.DemiBold
                    }
                }

                ListItem {
                    id: startTimeListitem

                    property date date: Date.fromLocaleString(Qt.locale(), settings.startTime, "hh:mm")

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
                    text: i18n.tr("Warning: Lower value will make the scheduled switching more accurate but may impact the battery.")
                    color: theme.palette.normal.negative
                    wrapMode: Text.Wrap
                    textSize: Label.Small

                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    Layout.leftMargin: units.gu(2)
                }
                
                ListItem {
                    id: hideIndicatorIcon

                    property bool bindValue: settings.alwaysHideIndicatorIcon
                    property bool switchValue: bindValue

                    width: parent.width

                    ListItemLayout {
                        anchors.centerIn: parent
                        title.text: i18n.tr("Always hide indicator icon")
                        subtitle.text: i18n.tr("This always hides the icon in the top panel instead of showing when dark mode is enabled.")

                        Switch {
                            id: checkItemHide
                            SlotsLayout.position: SlotsLayout.Trailing

                            //workaround where binding to status gets lost when the checkbox is clicked
                            Component.onCompleted: checkItemHide.checked = hideIndicatorIcon.bindValue
                            Connections {
                                target: hideIndicatorIcon
                                onBindValueChanged: {
                                    checkItemHide.checked = target.bindValue
                                }
                            }
                            onClicked: {
                                hideIndicatorIcon.switchValue = !hideIndicatorIcon.bindValue
                            }
                        }
                    }
                    onClicked: {
                        switchValue = !bindValue
                    }

                    onSwitchValueChanged: {
                        settings.alwaysHideIndicatorIcon = switchValue
                    }
                }

                ListItem {
                    id: switchLogging

                    property bool bindValue: settings.logging
                    property bool switchValue: bindValue

                    width: parent.width

                    ListItemLayout {
                        id: listItemLayout

                        anchors.centerIn: parent
                        title.text: i18n.tr("Indicator logging")
                        subtitle.text: i18n.tr("Useful for debugging")

                        Switch {
                            id: checkItem
                            SlotsLayout.position: SlotsLayout.Trailing

                            //workaround where binding to status gets lost when the checkbox is clicked
                            Component.onCompleted: checkItem.checked = switchLogging.bindValue
                            Connections {
                                target: switchLogging
                                onBindValueChanged: {
                                    checkItem.checked = target.bindValue
                                }
                            }
                            onClicked: {
                                switchLogging.switchValue = !switchLogging.bindValue
                            }
                        }
                    }
                    onClicked: {
                        switchValue = !bindValue
                    }

                    onSwitchValueChanged: {
                        settings.logging = switchValue
                    }
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
                Layout.fillWidth: true
            }

            

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: units.gu(2)
                Button {
                    id: installButton

                    text: !Indicator.isInstalled ? i18n.tr("Install Indicator") : i18n.tr("Uninstall Indicator")
                    onClicked: {
                        if (Indicator.isInstalled) {
                            Indicator.uninstall();
                        } else {
                            Indicator.install();
                        }
                    }
                    color: !Indicator.isInstalled ? LomiriColors.green : LomiriColors.red
                }
            }


            Label {
                id: message

                text: i18n.tr("Uninstall the indicator here before uninstalling the app!") + "\n"
                horizontalAlignment: Text.AlignHCenter
                color: LomiriColors.red
                wrapMode: Text.Wrap

                Layout.fillWidth: true
            }
        }
    }

    Connections {
        target: Indicator

        onInstalled: {
            if (success) {
                message.text = i18n.tr("Successfully installed!") + "\n" + i18n.tr("Please reboot to enable the indicator");
                message.color = LomiriColors.green;
                restartButton.visible = true;
            }
            else {
                message.text = i18n.tr("Failed to install");
                message.color = LomiriColors.red;
            }
        }

        onUninstalled: {
            if (success) {
                message.text = i18n.tr("Successfully uninstalled!") + "\n" + i18n.tr("Please reboot to enable the indicator");
                message.color = LomiriColors.green;
                restartButton.visible = true;
            }
            else {
                message.text = i18n.tr("Failed to uninstall");
                message.color = LomiriColors.red;
            }
        }
    }

    //initiate a python component for calls to python commands
    Python {
        id: py

        Component.onCompleted: {
            //this works as the import statement in a python script
            importModule('os', function() { console.log("DEBUG: python module os loaded"); });
        }
    }

}
