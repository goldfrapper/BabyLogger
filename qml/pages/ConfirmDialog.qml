import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property alias title: headerItem.title
    property alias description: contentItem.text
    
    Column {
        spacing: 10
        anchors.fill: parent
        
        DialogHeader {
            id: headerItem
        }
        
        Label {
            id: contentItem
            color: Theme.primaryColor
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeSmall

            x: Theme.paddingLarge
            width: parent.width - 2*Theme.paddingLarge
        }
    }
}
