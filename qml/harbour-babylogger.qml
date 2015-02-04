import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "components"

ApplicationWindow
{
    id: mainwindow

    property string appName: qsTr("Baby Logger");
    property string appVersion: qsTr("0.4.5");
    property bool is_development: true

    // Instantiate Settings
    Settings {
        id: settings
    }
    property alias settings: settings

    // Instantiate BabyModel
    BabyModel {
        id: babymodel
    }
    default property alias babymodel: babymodel

    Component {
        id: notification_dialog
        NotificationDialog {}
    }

    initialPage: Component { FirstPage {} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
