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
    
    // TODO: calculate these from usage statistics
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

            Button {
                text: qsTr("Breast milk")
                onClicked: logMealDialog.setSelection(0,0)
            }
            Button {
                text: qsTr("Formula 60ml")
                onClicked: logMealDialog.setSelection(1,60)
            }
            Button {
                text: qsTr("Formula 120ml")
                onClicked: logMealDialog.setSelection(1,120)
            }
        }
    }
}
