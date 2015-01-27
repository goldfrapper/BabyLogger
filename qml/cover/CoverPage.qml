import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

CoverBackground {
    anchors.fill: parent

    Label {
        id: pageHeader
        text: mainwindow.appName + " " + mainwindow.appVersion
        anchors.topMargin: Theme.paddingLarge
    }

    Counter {
        id: counter
        width: 100
        anchors.top: pageHeader.bottom
        active: (status === Cover.Active)
    }

    // TODO: Add cover actions for start/stop sleep and log meal
}
