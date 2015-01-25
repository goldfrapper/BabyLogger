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
//    id: dataSet

    // if the baby is sleeping
    property bool is_sleeping: false

    property double last_action_time: 0

    property bool is_development: false

    property variant meal_types: [qsTr("Breast milk"),qsTr("Formula"),qsTr("Pureed food")]

    // Load previously saved data
    Component.onCompleted: loadData()

    // DB Helper method
    function _getDatabaseHandle()
    {
        try {
            if(!is_development) {
                var db = LocalStorage.openDatabaseSync("babylogger", "log data", 10000);
            } else {
                var db = LocalStorage.openDatabaseSync("babylogger_dev","","log data", 10000, function(db)
                {
                    db.transaction(function(tx)
                    {
                        try {
                            var rs = tx.executeSql("
                            CREATE TABLE IF NOT EXISTS actions(date INTEGER, name TEXT)
                            CREATE TABLE IF NOT EXISTS meal (date INTEGER, type TEXT, qty INTEGER)");
                        } catch(e) {
                            // TODO show warning
                            console.log("fuck", e);
                        }
                    });
                    db.changeVersion("", "1.0");
                });
            }
        } catch(e) {
            if(e.code === SQLException.VERSION_ERR) {
                console.log("Version error");

                db.changeVersion("", "1.0");
            }
//                SQLException.DATABASE_ERR
        }

        return db;
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

    /**
     * Log action
     */
    function logMeal( type, quantity )
    {
        var ts = Date.now();

        // Validate
        if(meal_types.indexOf(type) === -1 || parseInt(quantity) !== quantity) {
            // TODO
            console.log("Invalid input data");
        }

        // Store data
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            try {
                var rs = tx.executeSql("INSERT INTO meal VALUES(?,?,?)", [ts, type, quantity]);
                if(!rs.rowsAffected) {
                    console.log("failed", rs.rowsAffected);
                } else {

                    // Update model
                    insert(0, {date: ts, action: "meal" });
                }
            } catch(e) {
                // TODO show warning
                console.log("fuck", e);
            }
        });
    }

    function getMealInfoString( date )
    {
        var str = "?";

        // Validate
        if( parseInt(date) !== date ) {
            // TODO
            console.log("Given date is not valid");
            str = "Error";
        }

        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            try {
                var rs = tx.executeSql("SELECT * FROM meal WHERE date = ? LIMIT 1", [date]);
                if(!rs.rows.length) {
                    console.log("There was no data available for " + date);
                    str = "Error";
                } else {
                    var row = rs.rows.item(0);
                    str = row.type + " " + row.qty + " ml"
                }
            } catch(e) {
                // TODO show warning
                console.log("fuck", e);
                str = "Error";
            }

            return str;
        });

        return str;
    }

    // LocalStorage function
    function loadData()
    {
        //console.log("loading datamodel");

        // Load previous data
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            // Create if not exists
            var out = tx.executeSql("CREATE TABLE IF NOT EXISTS actions(date INTEGER, name TEXT)");
            var out = tx.executeSql("CREATE TABLE IF NOT EXISTS meal (date INTEGER, type TEXT, qty INTEGER)");

            // Clear current data
            if(count) clear();

            // Load data
            var day = new Date();
            var res = tx.executeSql("
                SELECT * FROM actions
                UNION
                SELECT date, 'meal' FROM meal
                ORDER BY date DESC LIMIT 300
            ");
            for(var i = 0; i < res.rows.length; i++) {
                var row = res.rows.item(i);
                day.setTime(row.date);
                append({
                       date: row.date,
                       action: row.name,
                       day: day.toISOString().substring(0,10)
                });
            }
        });

        // When data is available set last "sleep" action as current mode
        if(count) {
            var last = getPrevSleepAction(-1);
            if(last) {
                last_action_time = last.date;
                is_sleeping = (last.action === "sleep_stop")? false : true;
            }

//            var last = get(0);
//            if(last.action === "sleep_stop" || last.action === "sleep_start") {
//                is_sleeping = (last.action === "sleep_stop")? false : true;
//                last_action_time = last.date;
//            }
//            last_action_time = get(0).date;
//            is_sleeping = (get(0).action === "sleep_stop")? false : true;
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
     * Returns the previous "sleep_*" action
     */
    function getPrevSleepAction( index )
    {
        var idx = index || 0;
        while( (idx++) < count ) {
            var prev = get(idx);
            if(!prev) { console.log("Faulty index " + index); return false;}
            if(prev.action === "sleep_start" || prev.action === "sleep_stop") {
                return prev
            }
        }
        return false
    }

    /**
     * Returns the duration of the given sleep/awake (index referencing end time)
     */
    function calcDuration( index )
    {
        if(index >= count) return "?";
        var start = getPrevSleepAction(index);
        if(!start) return "?";

        function pad(number) {
            return (number < 10)? '0' + number : number ;
        }

        var d = new Date( get(index).date - start.date );
        return pad(d.getUTCHours()) + "h" + pad(d.getUTCMinutes());
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
    function updateLogEntry( index, new_timestamp )
    {
        var curr = get( index );
        if(!curr) {
            return false;
        }

        // Should not be in the future
        if(new_timestamp > Date.now()) {
            // TODO show warning
            console.log("nah...");
            return false;
        }

        // Check if requested time does not mess up timeline
        // ie: should not be before the previous logged time
        var prev = get( index + 1 );
        var next = (index !== 0)? get( index - 1 ) : false;
        if( new_timestamp <= prev.date || (next && next.date <= new_timestamp)) {
            // TODO show warning
            console.log("nah...");
            return false;
        }

        // Store data in DB
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {

            var sql = "UPDATE actions SET date = ? WHERE date = ?";
            try {
                var rs = tx.executeSql(sql, [new_timestamp, curr.date]);
                if(!rs.rowsAffected) {
                    console.log("failed", rs.rowsAffected);
                } else {
                    // Update model
                    setProperty(index, "date", new_timestamp );
                    if(index === 0 && get(index).action.indexOf("sleep") === 0) {
                        last_action_time = new_timestamp;
                    }
                }
            } catch(e) {

                // TODO show warning
                console.log("fuck", e);
            }
        });
    }

    /**
     * Verify if given entry can be deleted
     * (At this point only last entry and meals)
     */
    function isRemovable( index )
    {
        var curr = get( index );
        if(!curr) return false;
        if(index === 0 || curr.action === "meal") return true;
        else return false
    }

    /**
     * Removes the given log entry
     */
    function removeLogEntry( index )
    {
        if(!isRemovable(index)) {
            // TODO show warning
            return false;
        }

        var curr = get(index);

        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            var table = (curr.action === "meal")? "meal" : "actions";
            var sql = "DELETE FROM " + table + " WHERE date = ?";

            try {

                var rs = tx.executeSql(sql, [curr.date]);
                if(!rs.rowsAffected) {
                    // TODO show warning
                    console.log("failed for index: " + index + ", date: " + curr.date);
                } else {

                    // Update model
                    remove(index);
                    if(index === 0) {
                        var prev = getPrevSleepAction(-1);
                        last_action_time = (prev)? prev.date : 0;
                    }
                }
            } catch(e) {

                // TODO show warning
                console.log("fuck", e);
            }
        });
    }
}
