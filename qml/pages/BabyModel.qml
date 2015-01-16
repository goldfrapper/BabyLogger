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
import QtQuick.LocalStorage 2.0

ListModel {
    id: dataSet

    // if the baby is sleeping
    property bool is_sleeping: false

    property double last_action_time: 0

    // Load previously saved data
    Component.onCompleted: loadData()

    // DB Helper method
    function _getDatabaseHandle()
    {
          return LocalStorage.openDatabaseSync("babylogger", "log data", 10000);
    }

    // Start/Stop sleeping
    function toggleSleep()
    {
        var d = new Date();
        var ts = d.getTime()
        var act = (is_sleeping? "sleep_stop" : "sleep_start");
        insert(0, {date: ts, action: act });

        // Store data in DB
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            tx.executeSql('INSERT INTO actions VALUES(?, ?)', [ ts, act ]);
        });

        last_action_time = ts;
        is_sleeping = !is_sleeping;
        return is_sleeping;
    }

    // LocalStorage function
    function loadData()
    {
        console.log("loading datamodel");

        // Load previous data
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            // Create if not exists
            var out = tx.executeSql("CREATE TABLE IF NOT EXISTS actions(date INTEGER, name TEXT)");

            // Load data
            var res = tx.executeSql("SELECT * FROM actions ORDER BY date DESC LIMIT 30");
            for(var i = 0; i < res.rows.length; i++) {
                append({date: res.rows.item(i).date, action: res.rows.item(i).name });
            }
        });

        // When data is available set last action as current mode
        if(count) {
            last_action_time = get(0).date;
            is_sleeping = (get(0).action === "sleep_stop")? false : true;
        }
    }

    // Returns the current timer position in 00:00:00 format
    function getCurrentTimer()
    {
        var d = new Date();
        d.setTime(Date.now() - last_action_time);
        function pad(number) {
              return (number < 10)? '0' + number : number ;
        }
        return [pad(d.getUTCHours()), pad(d.getUTCMinutes()), pad(d.getUTCSeconds())].join(":");
    }

    /**
     * Returns true if baby has been awake/sleeping for too long
     */
    function alertUser()
    {
        if(!is_sleeping && (Date.now() - last_action_time) > ((90*60)*1000)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Returns the last sleep/awake periods
     * Format: [[ timestamp start, timestamp stop, timestamp duration],[...]]
     */
    function getLastSleepPeriods()
    {

        var dataSet = [];
        var i = 0;

        dataSet[i] = {start:0, stop: get(i).date, state: ""};
        i++;

        while( i < count ) {
            dataSet[i].start = get(i).date;
            dataSet[i].state = (get(i).action === "sleep_start")? "sleeping" : "awake";
            dataSet[i++] = {start:0, stop: get(i).date, state: ""};
        }

        return dataSet;
    }

    /**
     * Updates the log entry for the given timestamp into new_timestamp
     */
    function updateLogEntry( timestamp, new_timestamp )
    {
        // TODO: Validate

//        console.log(timestamp, new_timestamp);

        // Store data in DB
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            tx.executeSql('UPDATE actions SET date = ? WHERE date = ?', [ timestamp, new_timestamp ]);
        });
    }
}
