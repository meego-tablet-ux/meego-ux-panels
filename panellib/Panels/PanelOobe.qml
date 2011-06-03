/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

PanelContent {
    id: content
    contentHeight: col.height
    property alias text: oobeText.text
    property alias imageSource: oobeImage.source
    property alias extraContentModel: extra.model
    property alias extraContentDelegate: extra.delegate
    property alias textColor: oobeText.color

    Column {
        id: col
        width: parent.width
        anchors.bottom: parent.bottom
        Image {
            id: oobeImage
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Item {
            width: parent.width
            height: panelSize.contentTopMargin
        }
        Text {
            id: oobeText
            anchors.left: parent.left
            anchors.right:  parent.right
            font.family: panelSize.fontFamily
            font.pixelSize: panelSize.tileFontSize
            color: panelColors.tileDescTextColor
            wrapMode: Text.Wrap
        }
        Item {
            width: parent.width
            height: panelSize.contentTopMargin
        }
        Repeater {
            id: extra
        }
    }
}
