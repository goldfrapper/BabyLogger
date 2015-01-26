import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

ListModel {
    id: babyModel

    // Properties
    property bool is_sleeping: false
    property double last_action_time: 0
    property bool is_development: false
    property variant meal_types: [qsTr("Breast milk"),qsTr("Formula"),qsTr("Pureed food")]
    property double last_meal_time: 0

    // Signals
    signal sleepModeChange( bool is_sleeping )
    signal meal( int index )

    // OnComplete handling
    Component.onCompleted:
    {
        loadData()                                      // Load previously saved data

        babyModel.meal.connect(setMealCounters);        // Connect meal signal
        setMealCounters()                               // Update meal counters
    }

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

    /**
     * Unified way of creating Log entries (object) for the BabyModel
     */
    function createLogObject( timestamp, action )
    {
        var date = new Date( timestamp );
        return {
            date: timestamp,
            action: action,
            day: date.toISOString().substring(0,10)
        };
    }

    // Start/Stop sleeping
    function toggleSleep()
    {
        var d = new Date();
        var ts = d.getTime()
        var act = (is_sleeping? "sleep_stop" : "sleep_start");

//        insert(0, {date: ts, action: act });

        insert(0, createLogObject( ts, act));

        // Store data in DB
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            tx.executeSql('INSERT INTO actions VALUES(?, ?)', [ ts, act ]);
        });

        updateCurrentSleepMode();

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
                    insert(0, createLogObject(ts, "meal"));
                    babyModel.meal(0);
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
                    str = row.type
                    if(row.qty !== 0) str = str + " " + row.qty + " ml"
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

    function getPrevMeal( index )
    {
        var idx = index || -1;
        if(parseInt(idx) !== index || idx < -1 || idx >= count) {
            console.log("Index Out of bounds " + index + "/" + count);
        }

        while(++idx < count) {
            var curr = get(idx);
            if(curr && curr.action === "meal") return curr;
        }

        return false;
    }

    /**
     * Update the meal properties / counters
     */
    function setMealCounters()
    {
        var meal = babymodel.getPrevMeal(-1);
        last_meal_time = meal.date;
    }

    // LocalStorage function
    function loadData()
    {
//        console.log("App version" + Qt.application.version);

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
//                day.setTime(row.date);
//                append({
//                       date: row.date,
//                       action: row.name,
//                       day: day.toISOString().substring(0,10)
//                });
                append(createLogObject( row.date, row.name));
            }
        });

        // When data is available set last "sleep" action as current mode
        if(count) {
            updateCurrentSleepMode();

//            var last = getPrevSleepAction(-1);
//            if(last) {
//                last_action_time = last.date;
//                is_sleeping = (last.action === "sleep_stop")? false : true;
//            }
        }
    }

//    // Returns the current timer position in 00:00:00 format
//    function getCurrentTimer()
//    {
////        var d = new Date();
////        d.setTime(Date.now() - last_action_time);
////        function pad(number) {
////              return (number < 10)? '0' + number : number ;
////        }
////        return [pad(d.getUTCHours()), pad(d.getUTCMinutes()), pad(d.getUTCSeconds())].join(":");

//        return formatDuration(last_action_time);
//    }

    /**
     * Updates models sleep mode
     */
    function updateCurrentSleepMode()
    {
        var last_sleep_action = getPrevSleepAction(-1);
        if(!last_sleep_action) {
            last_action_time = 0;
            is_sleeping = false;
        } else {
            last_action_time = last_sleep_action.date;
            is_sleeping = (last_sleep_action.action === "sleep_stop")? false : true;
        }

        // Signal mode change
        babyModel.sleepModeChange(is_sleeping);
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
        if(idx >= count || idx < -1) {
            console.log("Index out of bounds: " + idx + "/" + count);
            return false;
        }

        while( ++idx < count ) {
            var prev = get(idx);
            if(!prev) {
                console.log("Could not get object for index " + idx + "/" + count);
                return false;
            }
            if(prev.action.indexOf("sleep_") === 0) return prev;
        }
        return false
    }

    /**
     * Returns the next "sleep_*" action (or false if none)
     */
    function getNextSleepAction( index )
    {
        if(index < 1 || index > count) {
            console.log("Faulty index " + index);
            return false;
        }
        var idx = index;
        while(--idx >= 0) {
            var next = get(idx);
            if(!next) {
                console.log("Faulty index " + index);           // This should never happen
                return false;
            }
            if(next.action === "sleep_start" || next.action === "sleep_stop") {
                return next
            }
        }
        return false
    }

    /**
     * Returns the duration of the given sleep/awake (index referencing end time)
     */
    function calcDuration( index )
    {
        var idx = parseInt(index);
        if(idx !== index || idx < 0 || idx >= count) {
            return "?";
        }

        var curr = get(index);
        if(!curr) {
            console.log("Faulty index " + index + "/" + count);    // This should not happen
            return "?";
        }

        var start = getPrevSleepAction(index);
        if(!start) return "?";

//        function pad(number) {
//            return (number < 10)? '0' + number : number ;
//        }

//        var d = new Date( curr.date - start.date );
//        return pad(d.getUTCHours()) + "h" + pad(d.getUTCMinutes());

        return formatDuration( start.date, "h", curr.date);
    }

    /**
     * Small helper function to consistantly format durations
     */
    function formatDuration( starttime, format, endtime )
    {
        endtime = endtime || Date.now();
        var date = new Date( endtime - starttime );

        // Create duration array
        var d = [date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds()];
        d.forEach(function(v,i,a) { a[i] = (v < 10)? '0' + v : v; });

        switch(format) {
            case "h":
                return d[0] + "h" + d[1];
            case "hm":
                return d[0] + "h " + d[1] + "m";
            default:
                return d.join(":");
        }
    }

    /**
     * Returns the last sleep/awake periods
     * Format: [[ timestamp start, timestamp stop, timestamp duration],[...]]
     */
//    function getLastSleepPeriods()
//    {

//        var dataSet = [];
//        var i = 0;

//        dataSet[i] = {start:0, stop: get(i).date, state: ""};
//        i++;

//        while( i < count ) {
//            dataSet[i].start = get(i).date;
//            dataSet[i].state = (get(i).action === "sleep_start")? "sleeping" : "awake";
//            dataSet[i++] = {start:0, stop: get(i).date, state: ""};
//        }

//        return dataSet;
//    }

    /**
     * Updates the log entry for the given timestamp into new_timestamp
     */
    function updateLogEntry( index, new_timestamp )
    {
        // Given entry should exist
        var curr = get( index );
        if(!curr) {
            return false;
        }

        var is_sleep_action = (curr.action.indexOf("sleep_") === 0)? true : false;

        // Should not be in the future
        if(new_timestamp > Date.now()) {
            // TODO show warning
            console.log("nah...");
            return false;
        }

        // If action is sleep_* the requested time should not mess up timeline
        // ie: should not be sooner/later then previous/next logs (eg: 2 times sleep_start)
        if(is_sleep_action) {
            var prev = getPrevSleepAction(index);
            var next = getNextSleepAction(index);

            if( new_timestamp <= prev.date || (next && next.date <= new_timestamp)) {
                // TODO show warning
                console.log("nah...");
                return false;
            }
        }

        // Store data in DB
        var db = _getDatabaseHandle();
        db.transaction(function(tx)
        {
            var table = (curr.action === "meal")? "meal" : "actions";
            var sql = "UPDATE " + table + " SET date = ? WHERE date = ?";

            try {
                var rs = tx.executeSql(sql, [new_timestamp, curr.date]);
                if(!rs.rowsAffected) {
                    console.log("failed", rs.rowsAffected);
                } else {
                    // Update model
                    set( index, createLogObject(new_timestamp, curr.action));

//                    var date = new Date(new_timestamp);
//                    setProperty(index, "date", new_timestamp );
//                    setProperty(index, "day", date.toISOString().substring(0,10) );

                    updateCurrentSleepMode();

                    if(curr.action === "meal") babyModel.meal(index);

//                    if(index === 0 && get(index).action.indexOf("sleep") === 0) {
//                        last_action_time = new_timestamp;
//                        is_sleeping = (prev && prev.action === "sleep_stop")? false : true;
//                    }
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
                    updateCurrentSleepMode();

                    if(curr.action === "meal") babyModel.meal(index);
                }
            } catch(e) {

                // TODO show warning
                console.log("fuck", e);
            }
        });
    }
}
