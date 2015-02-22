import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

CoverBackground {
    anchors.fill: parent

    Label {
        id: pageHeader
        text: mainwindow.appName
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter

        height: Theme.itemSizeExtraSmall
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingSmall
        x: Theme.paddingSmall
    }

    Counter {
        id: counter

        active: (babymodel.count !== 0) && (status === Cover.Activating || status === Cover.Active)

        flowSpacing: 0
        labelHeight: 45

        width: parent.width
        anchors.top: pageHeader.bottom
        x: Theme.paddingSmall
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-timer"
            onTriggered: babymodel.toggleSleep()
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../pages/LogMealDialog.qml"));
                mainwindow.activate();
            }
        }
    }
}
