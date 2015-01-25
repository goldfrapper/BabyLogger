import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    model: mainwindow.babymodel

    contentHeight: (count * Theme.itemSizeExtraSmall)

    /**
     * TODO: Add Sections for dates
     */
    delegate: BackgroundItem {

        height: Theme.itemSizeExtraSmall


        Rectangle {
            height: parent.height
//            width: parent.width - (2 * Theme.paddingLarge)
//            border.color: "white"

            width: childrenRect.width
            color: (action === "sleep_stop")? Theme.rgba("white", 0.2) : Theme.rgba("white", 0.0);

            Row {
                spacing: 20
//                anchors.margins: Theme.paddingLarge
                x: Theme.paddingLarge
                width: parent.width - (2 * Theme.paddingLarge)

                Label {
                    text: formatStartTime(index)
                    verticalAlignment: Text.AlignVCenter
                    height: Theme.itemSizeExtraSmall
                }
                Label {
                    text: calcDuration( index )
//                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    height: Theme.itemSizeExtraSmall
                }
                Label {
                    text: (action === "sleep_stop")? "Sleeping" : "Awake";
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    verticalAlignment: Text.AlignVCenter
                    height: Theme.itemSizeExtraSmall
                }
            }
        }
    }

    function calcDuration( index )
    {
        function pad(number) {
            return (number < 10)? '0' + number : number ;
        }

        // Make shure next entry exists
        if((index + 1) === model.count) return "?";

        var start = model.get(index + 1).date;
        var date = model.get(index).date;
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

    function formatTimespan( index )
    {
        // Make shure next entry exists
        var date = model.get(index).date;
        if((index + 1) === model.count) return "?";
        return formatTime(model.get(index + 1).date) + " - " + formatTime(date);
    }

    function formatStartTime( index )
    {
        if((index + 1) === model.count) return "?";
        return formatTime(model.get(index + 1).date);
    }
}
