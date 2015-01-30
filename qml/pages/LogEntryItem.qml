import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: contentItem
    width: parent.width
    height: Theme.itemSizeExtraSmall

    property Item view

//    Component {
//        id: component_remorse_item
//        RemorseItem {}
//    }

    Label {
        id: log_startdate
        text: Qt.formatTime(new Date(date), "hh:mm");
        color: contentItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        
        x: Theme.paddingLarge
        height: Theme.itemSizeExtraSmall
        verticalAlignment: Text.AlignVCenter
    }
    Label {
        id: log_action
        text: view.model.action_labels[action]
        color: contentItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
        anchors.left: log_startdate.right
        anchors.leftMargin: Theme.paddingSmall
        height: Theme.itemSizeExtraSmall
        verticalAlignment: Text.AlignVCenter
    }
    
    Component.onCompleted: {
        if(action === "meal") {
            extra_meal.createObject(contentItem);
        } else {
            extra_sleep.createObject(contentItem);
        }
    }
    
    Component {
        id: extra_meal
        
        Label {
            id: log_meal
            enabled: (action === "meal")? true : false;
            text: mainwindow.babymodel.getMealInfoString(date)
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            height: Theme.itemSizeExtraSmall
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeSmall
        }
    }
    
    Component {
        id: extra_sleep
        
        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            
            Label {
                id: log_sleepmode
                text: (action === "sleep_stop")? qsTr("Sleeping") : qsTr("Awake");
                color: Theme.secondaryColor
                height: Theme.itemSizeExtraSmall
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeSmall
            }
            Label {
                id: log_duration
                text: mainwindow.babymodel.calcDuration( index )
                font.bold: true
                height: Theme.itemSizeExtraSmall
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    
    onPressAndHold: {

        if(!view.contextMenu) view.contextMenu = contextMenuComponent.createObject(view);

        // Fixes issue #24 with 'TypeError: Property 'show' of object ContextMenu_QMLTYPE_* is not a function'
        // NOTE THIS IS A WORKAROUND : this does *not* solve the real problem
        if(typeof view.contextMenu.show === "undefined") {
            view.contextMenu = contextMenuComponent.createObject(view);
        }

        // Setup the context menu
        view.contextMenu.currentIndex = index
        view.contextMenu.currentTimestamp = date;
        view.contextMenu.show(myListItem);
    }
    
    Component {
        id: contextMenuComponent
        
        ContextMenu {
            
            property double currentTimestamp: 0
            property int currentIndex: 0
            
            MenuItem {
                text: qsTr("Set time")
                onClicked: {
                    
                    var d = new Date(currentTimestamp);
                    
                    var orig = d.toString();
                    
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                    hour: d.getHours(),
                                                    minute: d.getMinutes(),
                                                    hourMode: DateTime.DefaultHours
                                                })
                    dialog.accepted.connect(function() {
                        
                        d.setHours( dialog.hour );
                        d.setMinutes( dialog.minute );
                        
                        remorse.execute(qsTr("Updating time"), function() {
                            view.model.updateLogEntry( currentIndex, d.getTime() );
                        });
                    })
                }
            }
            /* Disabled setting date
                        MenuItem {
                            text: qsTr("Set date")
                            onClicked: {
                                var d = new Date(currentTimestamp);
                                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: d
                                })
                                dialog.accepted.connect(function() {
                                
                                    d.setFullYear(dialog.year);
                                    d.setMonth(dialog.month - 1);
                                    d.setDate(dialog.day);
                                    
                                    remorse.execute("Updating date", function() {
                                        view.model.updateLogEntry( currentIndex, d.getTime() );
                                    });
                                })
                            }
                        }
                        */
            
            // Delete entry (only for first log item)
            MenuItem {
                text: qsTr("Delete")
                visible: view.model.isRemovable(currentIndex)? true : false
                onClicked: {
                    remorse.execute(qsTr("Deleting entry"), function() {
                        // Do nothing yet
                        view.model.removeLogEntry( currentIndex )
                    });

//                    var remorse = component_remorse_item.createObject(myListItem);
//                    remorse.execute(myListItem, qsTr("Deleting entry"), function() {
//                        view.model.removeLogEntry( currentIndex )
//                    });
                }
            }
        }
    }
}
