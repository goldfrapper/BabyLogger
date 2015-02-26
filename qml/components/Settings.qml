import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    id: settings
    property string max_awake_time: "01:30"
    property string max_meal_time: "04:00"
    property string time_since_startmeal: "00:10"
    
    Component.onCompleted:
    {
        var db = babymodel._getDatabaseHandle();
        db.transaction(function(tx)
        {
            try {
                var rs = tx.executeSql("SELECT * FROM setting");
                if(!rs.rows.length) {
                    console.log("There was no data available");
                } else {
                    for(var i = 0; i < rs.rows.length; i++) {
                        var row = rs.rows.item(i);
                        switch(row.key) {
                        case "max_awake_time": max_awake_time = row.value; break;
                        case "max_meal_time": max_meal_time = row.value; break;
                        case "time_since_startmeal": time_since_startmeal = row.value; break;
                        }
                    }
                }
            } catch(e) {
                // TODO show warning
                console.log("fuck", e);
            }
        });
    }
    
    function set( key, value )
    {
        var db = babymodel._getDatabaseHandle();
        db.transaction(function(tx)
        {
            try {
                var rs = tx.executeSql("INSERT OR REPLACE INTO setting (key,value) VALUES (?,?)", [key, value]);
                if(!rs.rowsAffected) {
                    console.log("Could not save");
                } else {
                    switch(key) {
                    case "max_awake_time": max_awake_time = value; break;
                    case "max_meal_time": max_meal_time = value; break;
                    case "time_since_startmeal": time_since_startmeal = value; break;
                    }
                }
            } catch(e) {
                // TODO show warning
                console.log("fuck", e);
            }
        });
    }
}
