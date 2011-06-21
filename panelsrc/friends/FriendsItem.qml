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

    width: parent.width
    imageVisible: false
    mouseAreaActive: false

    property string authorIcon: ""
    property string openUrl: ""

    property string serviceName: ""
    property string serviceIcon: ""
    //Ugly hack for the moment, as the more general service name isn't available from ContentAggregator
    property string serviceIconThemed: "image://themedimage/icons/services/" + serviceName.toLowerCase()
    property string authorName: ""
    property string messageText: ""
    property string picImage: ""
    property string timeStamp: ""
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

    contents: Item {
        width: parent.width
        height: row.height
        Connections {
            target: fpContainer
            onCheckVisible: {
    //            console.log("readTimer onTriggered for itemID " + itemID);
                if (amIVisible()) {
                    friendItemText.read(itemID);
                }
            }
        }
        Row {
            id: row
            height: Math.max(author.height, col.height)
            Item {
                id: author
                height: authorIconImage.height + panelSize.secondaryTileTopMargin
                width: authorIconImage.width
                TileIcon {
                    id: authorIconImage
                    imageHeight: panelSize.secondaryIconImageSize
                    imageWidth: panelSize.secondaryIconImageSize
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
                        property bool usedServiceIcon: false
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        height: Math.min(panelSize.serviceIconSize, sourceSize.height)
                        width: Math.min(panelSize.serviceIconSize, sourceSize.height)
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        asynchronous: true
                        source: (serviceIconThemed == "" ? (serviceIcon == "" ? "image://themedimage/icons/services/generic" : serviceIcon ) : serviceIconThemed)
                        onStatusChanged: {
                            if (status == Image.Error) {
                                if (usedServiceIcon) {
                                    source = "image://themedimage/icons/services/generic";
                                } else {
                                    usedServiceIcon = true;
                                    source = serviceIcon;
                                }
                            }
                        }
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
                        text: authorName
                        anchors.left: parent.left
                        font.family: panelSize.fontFamily
                        font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                        color: panelColors.tileMainTextColor //THEME - VERIFY
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                    }
                    Text {
                        id: timestampText
                        text: timeStamp
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
                    // Should we use multiline text elide? support available in Qt 4.8
                    id: contentText
                    text: messageText
                    width: parent.width
                    font.family: panelSize.fontFamily
                    font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                    color: panelColors.tileDescTextColor //THEME - VERIFY
                    wrapMode: Text.Wrap
                    clip: true
                }
                Item {
                    width: 1
                    height: panelSize.contentAreaSideMargin
                    visible: pictureImage.visible || requestBtns.visible
                }
                TileIcon {
                    id: pictureImage
                    imageSource: picImage
                    visible: (imageSource == "" ? false : true)
                    imageHeight: panelSize.secondaryIconImageSize
                    imageWidth: panelSize.secondaryIconImageSize
                    zoomImage: true
                    fillMode: Image.PreserveAspectCrop
                    smooth: !friendItemText.moving
                    asynchronous: true
                }
                Flow {
                    id: requestBtns
                    width: parent.width
                    spacing: panelSize.contentAreaSideMargin
                    visible: (friendItemText.itemType == "request")
                    Button {
                        id: acceptBtn
                        active: true
                        maxWidth: parent.width
                        text: qsTr("Accept")
                        onClicked: {
                            friendItemText.acceptClicked(itemID);
                        }
                    }

                    Button {
                        id: rejectBtn
                        active: true
                        maxWidth: parent.width
                        text: qsTr("Decline")
                        onClicked: {
                            friendItemText.rejectClicked(itemID);
                        }
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: friendItemText.clicked(itemID)
            onPressAndHold: friendItemText.pressAndHold(itemID, mouse)
        }
    }
}
