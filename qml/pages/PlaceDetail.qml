
import QtQuick 2.0
import Sailfish.Silica 1.0


import harbour.osmscout.map 1.0

import "../custom"

Page {
    id: placeDetailPage

    property double placeLat: 0.1;
    property double placeLon: 0.2;

    property bool infoReady: false;

    onStatusChanged: {
        if (status == PageStatus.Activating){
            infoReady = false;
            map.showCoordinatesInstantly(placeLat, placeLon);
            map.addPositionMark(0, placeLat, placeLon);
        }
    }

    function formatCoord(lat, lon){
        // use consistent GeoCoord toString method
        return  (Math.round(lat * 100000)/100000) + " " + (Math.round(lon * 100000)/100000);
    }

    Drawer {
        anchors.fill: parent

        dock: placeDetailPage.isPortrait ? Dock.Top : Dock.Left
        open: true

        background:  SilicaFlickable{

            anchors.fill: parent

            Column {
                id: placePanel

                width: parent.width

                spacing: Theme.paddingMedium


                Row{
                    spacing: Theme.paddingMedium
                    anchors.right: parent.right
                    Label {
                        id: placeLocationLabel
                        text: formatCoord(placeLat, placeLon)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    IconButton{
                        icon.source: "image://theme/icon-m-clipboard"
                        onClicked: {
                            Clipboard.text = placeLocationLabel.text
                        }
                    }
                }

                BusyIndicator {
                    id: busyIndicator
                    running: !infoReady
                    size: BusyIndicatorSize.Large
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Map {
          id: map
          //focus: true
          anchors.fill: parent
          showCurrentPosition: true
        }
    }
}