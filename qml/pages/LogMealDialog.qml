import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: logMealDialog
    
    function setSelection( type, quantity )
    {
        d_select.currentIndex = type
        d_quantity.value = quantity
    }
    
    onAccepted: {
        mainwindow.babymodel.logMeal( d_select.currentItem.text, d_quantity.value)
    }
    
    DialogHeader {
        id: d_header
        acceptText: qsTr("Add")
    }
    
    // Type
    ComboBox {
        id: d_select
        width: parent.width
        label: qsTr("Meal Type")
        currentIndex: 1

        description: qsTr("Select the type of food given. Currently supported types are breastmilk, formula and pureed food.")
        
        anchors.top: d_header.bottom
        
        menu: ContextMenu {
            Repeater {
                model: mainwindow.babymodel.meal_types
                MenuItem {
                    text: modelData
                }
            }
        }
    }
    
    // Quantity
    Slider {
        id: d_quantity
        width: parent.width
        anchors.top: d_select.bottom
        label: qsTr("Quantity")
        
        minimumValue: 0
        maximumValue: 250
        value: 60
        stepSize: 1
        valueText: value + " ml"
    }

    BackgroundItem {
        id: common_choices
        width: parent.width
        height: Theme.itemSizeSmall * 3
        anchors.top: d_quantity.bottom
        anchors.topMargin: Theme.paddingLarge

        Column {
            x: Theme.paddingLarge
            width: parent.width

            Label {
                text: qsTr("Common choices:")
            }

            Repeater {
                model: mainwindow.babymodel.getTopMeals();
                height: childrenRect.height
                Button {
                    text: modelData.title
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {

                        // Set selection
                        var typeId = mainwindow.babymodel.meal_types.indexOf(modelData.type)
                        logMealDialog.setSelection(typeId, modelData.qty);

                        // Accept dialog
                        logMealDialog.accept();
                    }
                }
            }
        }
    }

    ValueButton {
        anchors.top: common_choices.bottom
        anchors.topMargin: (Theme.paddingLarge * 2)
        label: qsTr("Time since start of meal:")
        description: qsTr("This amount is automaticly substracted from the current time")
        value: settings.time_since_startmeal

        onClicked: {
            var d = value.split(":");
            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                hour: d[0],
                minute: d[1],
                hourMode: DateTime.DefaultHours
            });

            dialog.accepted.connect(function() {
                value = dialog.timeText.substring(0,5);
                settings.set("time_since_startmeal", value);
            })
        }
    }
}
