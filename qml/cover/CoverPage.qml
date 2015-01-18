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
//import "../pages" as BabyLogger

CoverBackground {
    property bool active: (status === Cover.Active)
//    property Item baby_model: BabyLogger.BabyModel {}
    anchors.fill: parent

    Column {
        anchors.centerIn: parent

        Label {
            text: qsTr("Baby logger 0.2")
        }

        Label {
            id: counter_clock
            font.pixelSize: Theme.fontSizeHuge
            text: "00:00:00"
        }

        Label {
            id: counter_text
            text: "???"
            font.pixelSize: Theme.fontSizeMedium
        }

        Timer {
            interval: 500
            running: active
            repeat: true
            onTriggered: {
                counter_clock.text = mainwindow.babymodel.getCurrentTimer();
                counter_text.text = (mainwindow.babymodel.is_sleeping? qsTr("sleeping...") : qsTr("awake..."));
            }
        }



    }






//    CoverActionList {
//        CoverAction {
//            iconSource: "image://theme/icon-l-clock"
//        }
//    }

//    CoverActionList {
//        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-l-clock"
////            onTriggered: player.nextSong()
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-m-messaging-smiley-sleepy"
////            iconSource: "image://theme/icon-m-messaging-smiley-happy"
//        }
//    }
}


