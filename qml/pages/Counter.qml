import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    // Toggle whether the counter should run
    property alias active: counter_timer.running

    property int flowSpacing: 10
    property real labelHeight: Theme.itemSizeExtraSmall
    property real counterHeight: Theme.itemSizeExtraSmall

    // Sleep counter
    Flow {
        width: parent.width
        height: childrenRect.height
//        anchors.margins: Theme.paddingSmall
        spacing: flowSpacing

        Label {
            id: counter_clock
            text: "00:00:00"
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeHuge
            height: Theme.itemSizeExtraSmall
        }

        Label {
            id: counter_text
            text: "???"
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
            verticalAlignment: Text.AlignVCenter
            height: labelHeight
        }

        // Meal counter
        Flow {
            id: meal_counter
            width: parent.width
            height: childrenRect.height
            spacing: flowSpacing

            property string text: "00h 00m"

            Label {
                text: meal_counter.text
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                height: labelHeight
                verticalAlignment: Text.AlignVCenter
            }

            Label {
                text: qsTr("since last meal")
                color: Theme.secondaryColor
                height: labelHeight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Timer for all counters
    Timer {
        id: counter_timer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if(!mainwindow.babymodel.count) return;

            // Update counters
            counter_clock.text = babymodel.formatDuration(babymodel.last_action_time);
            counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));
            meal_counter.text = babymodel.formatDuration( babymodel.last_meal_time, "h" );

            // Verify if we need to alert user
            // TODO: this should be done using a 'alert-user' or 'awake-for-to-long' signal
            counter_clock.color = mainwindow.babymodel.alertUser()? "red" : Theme.primaryColor;
        }
    }
}
