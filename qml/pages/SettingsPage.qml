import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    RemorsePopup { id: remorse }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        VerticalScrollDecorator {}

        Column {
            id: content
            width: parent.width
            height: childrenRect.height
            spacing: 20

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Alerts and Timers")
            }

            // Maximum Awake Time
            ValueButton {
                label: qsTr("Max. Awake Time")
                value: settings.max_awake_time
                onClicked: {
                    var d = value.split(":");
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: d[0],
                        minute: d[1],
                        hourMode: DateTime.DefaultHours
                    });

                    dialog.accepted.connect(function() {
                        value = dialog.timeText.substring(0,5);
                        settings.set("max_awake_time", value);
                    })
                }

                description: qsTr("This value controls when the application should warn you that the baby has been awake for too long")
            }

            // Maximum "Between meals" time
            ValueButton {
                label: qsTr("Max. 'Between meals' Time")
                value: settings.max_meal_time;
                onClicked: {
                    var d = value.split(":");
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                        hour: d[0],
                        minute: d[1],
                        hourMode: DateTime.DefaultHours
                    });

                    dialog.accepted.connect(function() {
                        value = dialog.timeText.substring(0,5);
                        settings.set("max_meal_time", value);
                    })
                }

                description: qsTr("This is the maximum time that should be allowed between meals. This greatly depends on the age of the baby")
            }

            Separator {}

            SectionHeader {
                text: qsTr("Application Reset")
            }

            // Clear all data button
            Button {
                text: qsTr("Clear all logs")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    var dialog = pageStack.push(confirm_reset_dialog)
                    dialog.accepted.connect(function() {
                        mainwindow.babymodel.clearAllData();
                    })
                }
            }

            Component {
                id: confirm_reset_dialog
                ConfirmDialog {
                    title: qsTr("Reset Application")
                    description: qsTr("This will remove all saved data. Are you shure this is what you want? There is no easy way to undo this")
                }
            }
        }
    }
}
