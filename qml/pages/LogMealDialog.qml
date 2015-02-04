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
        label: qsTr("Type")
        currentIndex: 1
        
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
        maximumValue: 300
        value: 60
        stepSize: 10
        valueText: value + " ml"
    }

    BackgroundItem {
        width: parent.width
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
                Button {
                    text: modelData.type + " " + modelData.qty + "ml"
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
}
