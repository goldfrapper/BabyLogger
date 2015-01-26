import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
//    property BabyModel babyModel
//    height: childrenRect.height

    property alias active: counter_timer.running

    Flow {
        width: parent.width
        anchors.margins: Theme.paddingSmall
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

        // Move this to Counter?
        Flow {
            id: meal_counter
            width: parent.width
            spacing: 20

            property string text: "00h 00m"

            Label {
                text: meal_counter.text
                color: Theme.secondaryColor
            }

            Label {
                text: qsTr("since last meal")
                color: Theme.secondaryColor
            }
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
        counter_clock.text = babymodel.formatDuration(babymodel.last_action_time);
//        counter_clock.text = mainwindow.babymodel.getCurrentTimer();
        counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));

        meal_counter.text = babymodel.formatDuration( babymodel.last_meal_time, "h" );
        
        // When awake for more then 1h30 alert user
        if(mainwindow.babymodel.alertUser()) counter_clock.color = "red"
        else counter_clock.color = Theme.primaryColor
    }
}
