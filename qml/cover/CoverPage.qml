import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

CoverBackground {
    anchors.fill: parent

    Label {
        id: pageHeader
        text: mainwindow.appName + " " + mainwindow.appVersion
        font.pixelSize: Theme.fontSizeMedium

        height: Theme.itemSizeSmall
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        x: Theme.paddingSmall
    }

    Counter {
        id: counter
        active: (status === Cover.Active)

        flowSpacing: 0
        labelHeight: 50

        width: parent.width
        anchors.top: pageHeader.bottom
        x: Theme.paddingSmall
    }

    // TODO: Add cover actions for start/stop sleep and log meal
}
