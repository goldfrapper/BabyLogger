import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
//    property BabyModel babyModel
//    height: childrenRect.height

    Flow {
        width: parent.width
        spacing: 20

        Label {
            id: counter_clock
            text: "00:00:00"
            font.pixelSize: Theme.fontSizeHuge
            height: Theme.itemSizeSmall
        }

        Label {
            id: counter_text
            text: "???"
            font.pixelSize: Theme.fontSizeMedium
            verticalAlignment: Text.AlignVCenter
            height: Theme.itemSizeSmall
        }
    }

    Timer {
        id: counter_timer
        interval: 500
        running: true
        repeat: true
        onTriggered: updateTimer()
    }

    function updateTimer()
    {
        if(!mainwindow.babymodel.count) return;
        
        // Update counter
        counter_clock.text = mainwindow.babymodel.getCurrentTimer();
        counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));
        
        // When awake for more then 1h30 alert user
        if(mainwindow.babymodel.alertUser()) counter_clock.color = "red"
        else counter_clock.color = Theme.primaryColor
    }
}
