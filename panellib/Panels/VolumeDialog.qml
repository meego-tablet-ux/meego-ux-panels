/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Components 0.1 as Ux
import MeeGo.Panels 0.1

Item{

    id: bubbleContainer
    width: bubble.width
    height: bubble.height
    property alias dlgX: bubble.x
    property alias dlgY: bubble.y
    property alias offset: bubble.offset

    Ux.TopItem {
        id: topItem
    }

    MouseArea {
        id: maDlg
        parent: topItem.topItem
        anchors.fill: parent
        onClicked: {
            bubbleContainer.visible = false;
        }
        visible: bubbleContainer.visible
        VolumeControl {
            id: volCon
        }

        RectangularBubble {
            id: bubble
            offset: 0
            width: volCtrl.controllerWidth + 4
            height: volCtrl.controllerHeight + 4
            Item {
                anchors.margins: 2
                anchors.fill: parent
                VolumeController {
                    id: volCtrl
                    volumeControl: volCon
                    onClose: bubbleContainer.visible = false
                    volumeControlXmid: parent.width/2
                }
            }
        }
    }
}


