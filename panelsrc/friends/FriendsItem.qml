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

    height: contentHeight()
    width: parent.width

    property int maxHeight: panelSize.oneHalf
    property string authorIcon: ""
    property string openUrl: ""

    // property alias serviceName: serviceNameText.text
    property string serviceName: ""
    property string serviceIcon: "" //serviceIconImage.source
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
    function contentHeight() {
        return panelSize.secondaryTileHeight
        //return (timestampText.y + timestampText.height + timestampText.anchors.bottomMargin);
    }

    Row {
        id: row
        height: parent.height
        TileIcon {
            id: authorIconImage
            height: panelSize.secondaryTileContentHeight
            width: height
            anchors.verticalCenter: parent.verticalCenter
            imageSource: (authorIcon == "" ? "image://themedimage/images/im/bg_avatar_nopicture" : authorIcon)

            zoomImage: true
            // TODO: use .sci once there is support in image provider
            // (and an .sci file)
            source: "image://themedimage/widgets/apps/panels/item-border-item"
            border.top: 3
            border.bottom: 3
            border.left: 3
            border.right: 3
            fillMode: Image.PreserveAspectFit
            smooth: !friendItemText.moving
            asynchronous: true

        }
        Item {
            id: leftMargin
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Column {
            width: friendItemText.width - authorIconImage.width - leftMargin.width
            Item {
                id: topMargin
                width: 1
                height: panelSize.tileTextTopMargin
            }
            Item {
                width: parent.width
                height: authorNameText.height
                Text {
                    id: authorNameText
                    anchors.left: parent.left
                    font.family: panelSize.fontFamily
                    font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                    color: panelColors.tileMainTextColor //THEME - VERIFY
                    font.bold: true
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

            Text {
                id: contentText
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: panelSize.fontFamily
                font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                color: panelColors.tileDescTextColor //THEME - VERIFY
            }
        }
    }
        Image {
            id: pictureImage
            height: panelSize.oneThird //sourceSize.height
            width: panelSize.oneThird //calcPictureImageWidth()
            // anchors.top: contentText.bottom
            // anchors.topMargin: panelSize.contentTopMargin
            // anchors.left: contentText.left
            clip: true
            fillMode: Image.PreserveAspectCrop
            smooth: !friendItemText.moving
            asynchronous: true
            visible: (pictureImage.source == "" ? false : true)
            function calcPictureImageWidth() {

                if (pictureImage.sourceSize.width + authorNameText.anchors.leftMargin
                    + authorIconImage.width + authorIconImage.anchors.leftMargin > content.width) {
                    var size = content.width - (authorNameText.anchors.leftMargin
                        + authorIconImage.width + authorIconImage.anchors.leftMargin + 5);
                    return size;
                } else {
                    return pictureImage.sourceSize.width;
                }
            }
        }


        Button {
            id: acceptBtn
            visible: (friendItemText.itemType == "request")
//            bgSourceUp: "image://themedimage/images/panels/pnl_switch_pink_up"
//            bgSourceDn: "image://themedimage/images/panels/pnl_switch_pink_dn"
//            height: panelSize.oneTenth
//            width: panelSize.oneFourth
            // anchors.top: (pictureImage.visible ? pictureImage.bottom : contentText.bottom)
            // anchors.topMargin: panelSize.contentTopMargin
            // anchors.left: contentText.left
            text: qsTr("Accept")
            //color: theme.fontColorNormal
            onClicked: {
                friendItemText.acceptClicked(itemID);
            }
        }

        Button {
            id: rejectBtn
            visible: (friendItemText.itemType == "request")
//            height: panelSize.oneTenth
//            width: panelSize.oneFourth
            // anchors.top: (pictureImage.visible ? pictureImage.bottom : contentText.bottom)
            // anchors.topMargin: panelSize.contentTopMargin
            // anchors.left: acceptBtn.right
            // anchors.leftMargin: panelSize.contentSideMargin
            text: qsTr("Decline")
            //color: theme.fontColorNormal
            onClicked: {
                friendItemText.rejectClicked(itemID);
            }
        }
}
