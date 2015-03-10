import QtQuick 2.0
import Sailfish.Silica 1.0

//import org.nemomobile.dbus 2.0
//import org.freedesktop.contextkit 1.0


Page {
    id: page

    RemorsePopup { id: remorse }

    SilicaListView {
        id: listView
        model: mainwindow.babymodel
        anchors.fill: parent

        property Item contextMenu

        header: Item {
            id: headerContent
            height: childrenRect.height
            width: parent.width
            anchors.bottomMargin: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: mainwindow.appName + " " + mainwindow.appVersion
                anchors.right: parent.right
            }

            Counter {
                id: counter
                width: parent.width
                height: childrenRect.height
                anchors.top: pageHeader.bottom
                x: Theme.paddingLarge

                // Only activate when application/page is active and logs are available
                active: (babymodel.count !== 0) && (status === PageStatus.Active && applicationActive)
            }

            // Extra documentation / inline help when no data is available/logged
            Component {
                id: no_logs_warning
                Label {
                    text: qsTr("You have not yet logged anything. Start by selecting 'Start sleep' or 'Log meal' from the pull-down menu.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    anchors.topMargin: 2 * Theme.paddingLarge
                }
            }
            Loader {
                id: no_logs_warning_loader
                sourceComponent: no_logs_warning
                active: (babymodel.count === 0)

                onActiveChanged: {
                    if(!active) height = 0;     // Fixes issue with height remaining after deactivation
                }

                x: Theme.paddingLarge
                width: parent.width - (2* Theme.paddingLarge)
                anchors.top: counter.bottom
            }
        }

        section.property: "day"
//        section.labelPositioning: ViewSection.CurrentLabelAtStart

        section.delegate: BackgroundItem {
            height: Theme.itemSizeSmall
            anchors.rightMargin: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge

            Label {
                id: section_header
                text: Qt.formatDate(new Date(section))
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                width: parent.width
                anchors.rightMargin: Theme.paddingLarge
            }

            Row {
                anchors.top: section_header.bottom
                spacing: 5
                width: parent.width
                anchors.rightMargin: Theme.paddingLarge

                layoutDirection: Qt.RightToLeft

                Label {
                    function formatTotalSleepPerDay()
                    {
                        var total = babymodel.getTotalSleepPerDay(new Date(section));
                        return babymodel.formatDuration(0, "h", total * 1000);
                    }
                    text: formatTotalSleepPerDay()
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.highlightColor
                }
                Label {
                    text: qsTr("total sleep")
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.highlightColor
                }
            }
        }

        delegate: Item {
            id: myListItem
            property bool menuOpen: listView.contextMenu != null && listView.contextMenu.parent === myListItem

            width: ListView.view.width
            height: menuOpen ? listView.contextMenu.height + contentItem.height : contentItem.height

            LogEntryItem {
                id: contentItem
                view: listView
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Log Meal")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LogMealDialog.qml"))
                }
            }
            MenuItem {
                text: getButtonTitle()
                onClicked: {
//                    remorse.execute(text, function() {
                        mainwindow.babymodel.toggleSleep()   // Register start/stop
//                    });
                }

                Component.onCompleted: {
                    // Register setButtonTitle method with sleepModeChange event
                    mainwindow.babymodel.sleepModeChange.connect(setButtonTitle);
                }

                function setButtonTitle()
                {
                    text = getButtonTitle();
                }

                function getButtonTitle()
                {
                    return mainwindow.babymodel.is_sleeping? qsTr("Stop sleep") : qsTr("Start sleep");
                }
            }

//            MenuLabel {
//                text: qsTr("Actions Menu")
//            }
        }

        VerticalScrollDecorator {}
    }
}
