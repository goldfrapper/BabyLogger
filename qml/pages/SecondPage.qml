/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    RemorsePopup { id: remorse }

    SilicaListView {
        id: listView

        property Item contextMenu

        model: mainwindow.babymodel

        anchors.fill: parent
//        header: PageHeader {
//            title: qsTr("Baby logs")
//        }

        header: Item {
            height: childrenRect.height
            width: parent.width

            anchors.bottomMargin: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: qsTr("Baby Logger")
                anchors.right: parent.right
            }

            Counter {
                id: counter
                width: parent.width
                height: childrenRect.height
                anchors.top: pageHeader.bottom
                x: Theme.paddingLarge
            }
        }

        section.property: "day"
        section.delegate: SectionHeader {
            text: section
            height: Theme.itemSizeExtraSmall
        }

        function formatDate(ts)
        {
            function pad(number) {
                  return (number < 10)? '0' + number : number ;
            }
            var d = new Date();
            d.setTime(ts);
            var a = [ pad(d.getDate()), pad(d.getMonth() + 1), pad(d.getFullYear()) ].join("-");
            var b = [ pad(d.getHours()), pad(d.getMinutes()) ].join(":");
            return b;
        }

        delegate: Item {
            id: myListItem
            property bool menuOpen: listView.contextMenu != null && listView.contextMenu.parent === myListItem

            width: ListView.view.width
            height: menuOpen ? listView.contextMenu.height + contentItem.height : contentItem.height

            BackgroundItem {
                id: contentItem
                width: parent.width
                height: Theme.itemSizeExtraSmall

                Label {
                    id: log_startdate
                    text: listView.formatDate(date)
                    color: contentItem.highlighted ? Theme.highlightColor : Theme.primaryColor

                    x: Theme.paddingLarge
                    height: Theme.itemSizeExtraSmall
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    id: log_action
                    text: " " + action
                    color: contentItem.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    anchors.left: log_startdate.right
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
                            text: (action === "sleep_stop")? "Sleeping" : "Awake";
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
                    if (!listView.contextMenu) listView.contextMenu = contextMenuComponent.createObject(listView);

                    // Setup the context menu
                    listView.contextMenu.currentIndex = index
                    listView.contextMenu.currentTimestamp = date;
                    listView.contextMenu.show(myListItem);
                }
            }
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
//                        d.setTime( currentTimestamp );

                        var orig = d.toString();

                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                            hour: d.getHours(),
                            minute: d.getMinutes(),
                            hourMode: DateTime.DefaultHours
                        })
                        dialog.accepted.connect(function() {

                            d.setHours( dialog.hour );
                            d.setMinutes( dialog.minute );

                            remorse.execute("Updating time", function() {
                                listView.model.updateLogEntry( currentIndex, d.getTime() );
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
                                listView.model.updateLogEntry( currentIndex, d.getTime() );
                            });
                        })
                    }
                }
                */

                // Delete entry (only for first log item)
                MenuItem {
                    text: qsTr("Delete")
                    visible: listView.model.isRemovable(currentIndex)? true : false
                    onClicked: {
                        remorse.execute("Deleting entry", function() {
                            // Do nothing yet
                            listView.model.removeLogEntry( currentIndex )
                        });
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Log Meal")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LogMealDialog.qml"))
                }
            }
            MenuItem {
                text: getButtonTitle()
                onClicked: {
                    remorse.execute(getButtonTitle(), function() {
                        mainwindow.babymodel.toggleSleep()   // Register start/stop
                        text = getButtonTitle();             // Reset button timer
                    });
                }

                function getButtonTitle()
                {
                    return mainwindow.babymodel.is_sleeping? qsTr("Stop sleep") : qsTr("Start sleep");
                }
            }

            MenuLabel {
                text: qsTr("Actions Menu")
            }
        }

        VerticalScrollDecorator {}
    }
}





