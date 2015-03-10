import QtQuick 2.0

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
//    property alias title: headerItem.title
//    property alias description: contentItem.text

    Column {
        spacing: 10
        anchors.fill: parent

        DialogHeader {
            title: "Select Time"
        }

        TimePicker {
            hour: 13
            minute: 30
        }

        ValueButton {
            label: "Selected date"
            description: "test test test"
            value: "2012/11/23"

            onClicked: {
                var dialog = pageStack.push(pickerComponent, {
                    date: new Date('2012/11/23')
                })
                dialog.accepted.connect(function() {
                    button.text = "You chose: " + dialog.dateText
                })
            }

            Component {
                id: pickerComponent
                DatePickerDialog {}
            }
        }
    }
}
