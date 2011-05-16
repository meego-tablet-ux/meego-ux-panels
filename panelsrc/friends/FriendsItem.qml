/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

SecondaryTileBase {
    id: friendItemText

    height: row.height
    width: parent.width
    imageVisible: false

    property string authorIcon: ""
    property string openUrl: ""

    // property alias serviceName: serviceNameText.text
    property string serviceName: ""
    property string serviceIcon: ""
    property alias authorName: authorNameText.text
    property alias messageText: contentText.text
    property alias picImage: pictureImage.source
    property alias timeStamp: timestampText.text
//DEBUG    property string timeStamp
    property string itemID: ""
//DEBUG    property alias itemID: timestampText.text
    property string itemType: ""

    property bool moving: false

    signal pressAndHold(string myID, variant mouse)
    signal clicked(string myID)
    signal acceptClicked(string myID)
    signal rejectClicked(string myID)
    signal read(string myID)



    function amIVisible() {
/*        console.log("amIVisible? id: ", itemID, "visible: ", friendItemText.visible);
        console.log("amIVisible? fIT.idx: ", index, "fIT.height: ", friendItemText.height, " lvContent.height: ", lvContent.height, " h*idx: ", index * friendItemText.height);
        console.log("amIVisible? visArea.yPos: ", ListView.view.visibleArea.yPosition, "visArea.heightRatio: ", ListView.view.visibleArea.heightRatio, "LV.v.height: ", ListView.view.height);
        console.log("amIVisible? calcLV.view.y: ", ListView.view.visibleArea.yPosition * ListView.view.height, " calcLV.view.y*h: ", ListView.view.visibleArea.yPosition * ListView.view.contentHeight);
*/
        var minY = fiContainer.view.visibleArea.yPosition * fiContainer.view.contentHeight;
        var maxY = minY + fiContainer.view.height;
        var myMinY = index * friendItemText.height;
        var myMaxY = (index+1) * friendItemText.height;
/*
        console.log("amIVisible? minY: ", minY, "maxY: ", maxY);
        console.log("amIVisible? idx: ", index, "id: ", itemID, "myMinY: ", myMinY, "myMaxY: ", myMaxY);
*/
        if ((myMinY < minY) || (myMaxY > maxY)) {
//            console.log("amIVisible? false");
            return false;
        }
//        console.log("amIVisible? true");
        return true;
    }


    Connections {
        target: fpContainer
        onCheckVisible: {
//            console.log("readTimer onTriggered for itemID " + itemID);
            if (amIVisible()) {
                friendItemText.read(itemID);
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: friendItemText.clicked(itemID)
        onPressAndHold: friendItemText.pressAndHold(itemID, mouse)
    }

    Row {
        id: row
        height: Math.max(panelSize.secondaryTileHeight, col.height)
        Item {
            height: panelSize.secondaryTileHeight
            width: authorIconImage.width
            TileIcon {
                id: authorIconImage
                height: panelSize.secondaryTileContentHeight
                width: height
                anchors.verticalCenter: parent.verticalCenter
                imageSource: (authorIcon == "" ? "image://themedimage/widgets/apps/panels/avatar-default" : authorIcon)

                zoomImage: true
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://themedimage/widgets/apps/panels/item-border-item"
                border.top: 3
                border.bottom: 3
                border.left: 3
                border.right: 3
                fillMode: Image.PreserveAspectCrop
                smooth: !friendItemText.moving
                asynchronous: true
                Image {
                    id: serviceIconImage
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    height: Math.min(panelSize.serviceIconSize, sourceSize.height)
                    width: Math.min(panelSize.serviceIconSize, sourceSize.height)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    source: (serviceIcon == "" ? "image://themedimage/icons/services/generic" : serviceIcon)
                }
            }
        }
        Item {
            id: leftMargin
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Column {
            id: col
            width: friendItemText.width - authorIconImage.width - leftMargin.width
            Item {
                id: topMargin
                width: 1
                height: panelSize.tileTextTopMargin
            }
            Item {
                id: heading
                width: parent.width
                height: authorNameText.height
                Text {
                    id: authorNameText
                    anchors.left: parent.left
                    font.family: panelSize.fontFamily
                    font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                    color: panelColors.tileMainTextColor //THEME - VERIFY
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }
                Text {
                    id: timestampText
                    width: parent.width - authorNameText.width
                    anchors.right: parent.right
                    font.family: panelSize.fontFamily
                    font.pixelSize: panelSize.timestampFontSize //THEME - VERIFY
                    color: panelColors.tileDescTextColor //THEME - VERIFY
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }
            }
            Item {
                width: 1
                height: panelSize.tileTextLineSpacing
            }
            Text {
                // TODO multiline text elide. support available in Qt 4.8
                id: contentText
                width: parent.width
                height: Math.min(paintedHeight, panelSize.secondaryTileHeight - heading.height - 2*topMargin.height)
                font.family: panelSize.fontFamily
                font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                color: panelColors.tileDescTextColor //THEME - VERIFY
                wrapMode: Text.Wrap
                clip: true
            }
            Item {
                width: 1
                height: panelSize.secondaryTileGridSideMargin
                visible: pictureImage.visible || requestBtns.visible
            }
            TileIcon {
                id: pictureImage
                visible: (pictureImage.source == "" ? false : true)
                height: panelSize.tileListItemContentHeight
                width: panelSize.tileListItemContentHeight
                zoomImage: true
                fillMode: Image.PreserveAspectCrop
                smooth: !friendItemText.moving
                asynchronous: true
            }
            Item {
                id: requestBtns
                width: parent.width
                height: acceptBtn.height
                visible: (friendItemText.itemType == "request")
                Button {
                    id: acceptBtn
                    anchors.left: parent.left
                    anchors.leftMargin: panelSize.secondaryTileGridSideMargin // TODO
                    maxWidth: parent.width/2 - 1.5*anchors.leftMargin
                    text: qsTr("Accept")
                    onClicked: {
                        friendItemText.acceptClicked(itemID);
                    }
                }

                Button {
                    id: rejectBtn
                    anchors.right: parent.right
                    anchors.rightMargin: panelSize.secondaryTileGridSideMargin // TODO
                    maxWidth: parent.width/2 - 1.5*anchors.rightMargin
                    text: qsTr("Decline")
                    onClicked: {
                        friendItemText.rejectClicked(itemID);
                    }
                }
            }
        }
    }

}
