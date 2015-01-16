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

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show logs")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: contentColumn.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: contentColumn

            width: page.width
            height: parent.height
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Baby Logger")
            }

            Row {
                id: counter
                spacing: 20

                Label {
                    id: counter_clock
                    text: "00:00:00"
//                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeHuge
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.paddingLarge
                }

                Label {
                    id: counter_text
                    text: "???"
                    font.pixelSize: Theme.fontSizeMedium
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Theme.paddingLarge
                }

                Timer {
                    id: counter_timer
                    interval: 500
                    running: true
                    repeat: true
                    onTriggered: counter.updateTimer()
                }

                function updateTimer()
                {
                    if(!logListing.model.count) return;

                    // Update counter
                    counter_clock.text = logListing.model.getCurrentTimer();
                    counter_text.text = (logListing.model.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));

                    // When awake for more then 1h30 alert user
                    if(logListing.model.alertUser()) counter_clock.color = "red"
                    else counter_clock.color = Theme.primaryColor
                }
            }

            Row {
                id: actionButtons
                width: parent.width
                height: Theme.itemSizeMedium

                Button {
                   text: "???"

                   function setButtonTitle()
                   {
                       text = logListing.model.is_sleeping? qsTr("Stop sleep") : qsTr("Start sleep");
                   }

                   // Initiate button title at application start
                   Component.onCompleted: setButtonTitle()

                   onClicked: {
                       logListing.model.toggleSleep()       // Register start/stop
                       setButtonTitle();                    // Reset button timer
                       counter.updateTimer();               // Re-Initiate timer
                   }
                }
            }

            // TODO Add date-sections (ListView.section)
            SilicaListView {
                id: logListing
                model: BabyModel {}

                height: model.count * Theme.itemSizeExtraSmall
                anchors.top: actionButtons.bottom
                spacing: 0

                Component.onCompleted: incrementCurrentIndex() // ?????

                /**
                 * TODO: Add Sections for dates
                 */
                delegate: BackgroundItem {

                    function calcDuration()
                    {
                        function pad(number) {
                              return (number < 10)? '0' + number : number ;
                        }

                        // Make shure next entry exists
                        if((index + 1) === logListing.model.count) return "?";

                        var start = logListing.model.get(index + 1).date;
                        var d = new Date();
                        d.setTime((date - start));

                        return pad(d.getUTCHours()) + "h" + pad(d.getUTCMinutes());
                    }

                    function formatTime(ts)
                    {
                        function pad(number) {
                              return (number < 10)? '0' + number : number ;
                        }
                        var d = new Date();
                        d.setTime(ts);
                        return pad(d.getHours()) + "h" + pad(d.getMinutes());
                    }

                    function formatTimespan()
                    {
                        // Make shure next entry exists
                        if((index + 1) === logListing.model.count) return "?";
                        return "(" + formatTime(logListing.model.get(index + 1).date) + " - " + formatTime(date) + ")";
                    }

                    Row {
                        spacing: 20
                        Label {
                            text: calcDuration()
                        }
                        Label {
                            text: (action === "sleep_stop")? "Sleeping" : "Awake";
                        }
                        Label {
                            text: formatTimespan()
                        }
                    }
                }
                VerticalScrollDecorator {}
            }
        }
    }
}
