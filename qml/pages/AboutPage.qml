import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height


        Column {
            id: column
            width: parent.width
            height: childrenRect.height
            anchors.leftMargin: Theme.paddingLarge
            anchors.bottomMargin: Theme.paddingLarge
            spacing: 20

            PageHeader {
                title: qsTr("About")
            }

            Image {
                id: wplogo
                anchors.horizontalCenter: parent.horizontalCenter
                width: 86
                height: 86
                source: "qrc:///harbour-babylogger.png"
            }

            Label {
                text: mainwindow.appName + " " + mainwindow.appVersion
                font.pixelSize: Theme.fontSizeLarge
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr("Native SailfishOS application for monitoring/logging activity of a human baby.")
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Definition {
                width: parent.width
                labelText: qsTr("Developer")
                contentText: qsTr("Goldfrapper <goldfrapper@gmail.com>")
            }

            Definition {
                width: parent.width
                labelText: qsTr("GitHub Repository")
                contentText: qsTr("https://github.com/goldfrapper/BabyLogger/")
            }

            Definition {
                width: parent.width
                labelText: qsTr("Icon")
                contentText: qsTr("Icon based on the artwork of Yazmin Alanis (http://thenounproject.com/yalanis/)")
            }

            Definition {
                width: parent.width
                anchors.topMargin: Theme.paddingSmall
                labelText: qsTr("Translations")
                contentText: "Rikujolla (Finnish)"
            }

            Definition {
                width: parent.width
                anchors.topMargin: Theme.paddingSmall
                labelText: qsTr("Licence")
                contentText: "GPL Version 2"
            }
        }

        VerticalScrollDecorator {}
    }
}
