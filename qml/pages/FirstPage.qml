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

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: flickableThing

        anchors.fill: parent
//        anchors.leftMargin: Theme.paddingLarge
//        anchors.rightMargin: Theme.paddingLarge
//        anchors.verticalCenter: parent.verticalCenter

        // Tell SilicaFlickable the height of its content.
        contentHeight: contentColumn.height

        Component.onCompleted: {
            console.log("SilicaFlickable", width, height, contentHeight);
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {

            MenuItem {
                text: qsTr("Show logs")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: contentColumn
            spacing: Theme.paddingLarge

            anchors.margins: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter

            height: childrenRect.height

            Component.onCompleted: {
                console.log("Column",width, height, childrenRect.height);
            }

            PageHeader {
                title: qsTr("Baby Logger")

                Component.onCompleted: {
                    console.log("PageHeader",width, height);
                }
            }

            Rectangle {
                border.color: "#ffffff"
                color: Theme.rgba("black",0)
                border.width: 3
                radius: 10

                height: Theme.itemSizeMedium
                width: parent.width

                anchors.horizontalCenter: parent.horizontalCenter

//                Row {
                    id: counter
//                    spacing: 20
//                    anchors.leftMargin: 20

                    Component.onCompleted: {
                        console.log("counter",width, height);
                    }

                    Label {
                        id: counter_clock
                        text: "00:00:00"
                        font.pixelSize: Theme.fontSizeHuge
                    }

                    Label {
                        id: counter_text
                        text: "???"
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    Timer {
                        id: counter_timer
                        interval: 500
                        running: true
                        repeat: true
                        onTriggered: parent.updateTimer()
                    }

                    function updateTimer()
                    {
                        if(!mainwindow.babymodel.count) return;

                        // Update counter
                        counter_clock.text = mainwindow.babymodel.getCurrentTimer();
                        counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));

                        // When awake for more then 1h30 alert user
                        if(mainwindow.babymodel.alertUser()) counter_clock.color = "red"
                        else counter_clock.color = Theme.primaryColor
                    }
//                }
            }

            Row {
                id: actionButtons

                height: Theme.itemSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter

//                height: Theme.itemSizeMedium

//                width: parent.width
//                height: Theme.itemSizeMedium

                Component.onCompleted: {
                    console.log("actionButtons", width, height);
                }

                Button {
                    text: "???"

                    function setButtonTitle()
                    {
                       text = mainwindow.babymodel.is_sleeping? qsTr("Stop sleep") : qsTr("Start sleep");
                    }

                    // Initiate button title at application start
                    Component.onCompleted: setButtonTitle()

                    onClicked: {
                       mainwindow.babymodel.toggleSleep()       // Register start/stop
                       setButtonTitle();                    // Reset button timer
                       counter.updateTimer();               // Re-Initiate timer
                    }
                }

                Button {
                    text: "Eating"
//                    visible: mainwindow.babymodel.is_sleeping? false : true;
//                    Component.onCompleted: {}
//                    onClicked: {}
                }
            }

//            BackgroundItem {
//                 anchors.bottom: parent.bottom
//                 anchors.horizontalCenter: parent.horizontalCenter

//                 Label {
//                     text: "test"
//                 }
//            }

//            CalendarView {
//                id: logListing

////                width: parent.width
////                height: 600

//                anchors.top: actionButtons.bottom

//                Component.onCompleted: {
//                    console.log("CalendarView", contentHeight, height, contentColumn.height);
//                }
//                VerticalScrollDecorator {}
//            }
        }
        VerticalScrollDecorator {}
    }
}
