import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtFeedback 5.0

//import org.nemomobile.dbus 2.0

Item {

    // Toggle whether the counter should run
    property alias active: counter_timer.running

    property int flowSpacing: 10
    property real labelHeight: Theme.itemSizeExtraSmall
    property real counterHeight: Theme.itemSizeExtraSmall

    /**
     * Reset all counters
     */
    function reset()
    {
        counter_clock.text = "00:00:00";
        counter_text.text = "unknown";
        meal_counter.text = "00h 00m";
    }

    Component.onCompleted: {

        // When all data is erased, reset counters
        babymodel.allDataCleared.connect(reset);

        // When last meal time is reset
        babymodel.meal.connect(function()
        {
            if(babymodel.last_meal_time === 0) reset();
        });

        // When last action time is reset
        babymodel.sleepModeChange.connect(function()
        {
            if(babymodel.last_action_time === 0) reset();
        });
    }

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
            text: "unknown"
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
            property string color: Theme.primaryColor

            Label {
                text: meal_counter.text
                color: meal_counter.color
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
//            console.count("counter");
//            if(!mainwindow.babymodel.count) {
//                reset();
//                return;
//            }

            // Update counters
            if(babymodel.last_action_time !== 0) {
                counter_clock.text = babymodel.formatDuration(babymodel.last_action_time);
                counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));

                // Verify if we need to alert user
                // TODO: this should be done using a 'alert-user' or 'awake-for-to-long' signal
                counter_clock.color = mainwindow.babymodel.alertUser()? "red" : Theme.primaryColor;
                // notificator.running = mainwindow.babymodel.alertUser()
            }
            if(babymodel.last_meal_time !== 0) {
                meal_counter.text = babymodel.formatDuration( babymodel.last_meal_time, "hm" );

                // Check for alarm
                var d = new Date("1970-01-01T" + settings.max_meal_time + ":00");
                meal_counter.color = ((Date.now() - babymodel.last_meal_time) > d.getTime())? "red" : Theme.primaryColor;
            }
        }
    }

//    ThemeEffect {
//        id: longBuzz
//        effect: ThemeEffect.PressStrong
//    }

//    Timer {
//        id: notificator
//        interval: (20 * 1000)
//        running: false
//        repeat: true
//        onTriggered: {
//            longBuzz.play()
//        }
//    }
}
