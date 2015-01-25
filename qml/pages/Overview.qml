import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    RemorsePopup { id: remorse }

//    LogMealDialog {
//        id: logMealDialog
//    }

    CalendarView {
        id: logListing
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Log Meal")
                onClicked: {
//                    logMealDialog.open();
                    pageStack.push(Qt.resolvedUrl("LogMealDialog.qml"))
                }
            }
            MenuItem {
                text: getButtonTitle()
                onClicked: {
                    remorse.execute(getButtonTitle(), function() {
                        mainwindow.babymodel.toggleSleep()   // Register start/stop
                        text = getButtonTitle();             // Reset button timer
                    });
                }

                function getButtonTitle()
                {
                    return mainwindow.babymodel.is_sleeping? qsTr("Stop sleep") : qsTr("Start sleep");
                }
            }
            MenuItem {
                text: qsTr("Show logs")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }

            MenuLabel {
                text: qsTr("Actions Menu")
            }
        }

        header: Item {
            height: childrenRect.height
            width: parent.width

            anchors.bottomMargin: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: qsTr("Baby Logger")
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

        VerticalScrollDecorator {}
    }
}
