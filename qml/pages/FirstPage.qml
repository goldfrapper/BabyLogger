import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    RemorsePopup { id: remorse }

    SilicaListView {
        id: listView
        model: mainwindow.babymodel
        anchors.fill: parent

        property Item contextMenu

        header: Item {
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
            }
        }

        section.property: "day"
        section.delegate: SectionHeader {
            text: section
            height: Theme.itemSizeExtraSmall
            font.pixelSize: Theme.fontSizeMedium

//            Label {
//                text: "00:00 total sleep"
//                font.pixelSize: Theme.fontSizeTiny
//                anchors.bottom: parent.bottom
//            }
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
                text: qsTr("Log Meal")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LogMealDialog.qml"))
                }
            }
            MenuItem {
                text: getButtonTitle()
                onClicked: {
                    remorse.execute(text, function() {
                        mainwindow.babymodel.toggleSleep()   // Register start/stop
                    });
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

            MenuLabel {
                text: qsTr("Actions Menu")
            }
        }

        VerticalScrollDecorator {}
    }
}
