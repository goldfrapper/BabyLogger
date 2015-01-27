import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    // Toggle whether the counter should run
    property alias active: counter_timer.running

    // Sleep counter
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

        // Meal counter
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
