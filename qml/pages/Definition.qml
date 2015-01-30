import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property string labelText: "name"
    property string contentText: "value"
    
    height: childrenRect.height

    Label {
        id: label
        text: labelText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
    }
    
    Label {
        text: contentText
        color: Theme.secondaryColor
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        width: parent.width
        anchors.top: label.bottom
        font.pixelSize: Theme.fontSizeSmall
    }
}
