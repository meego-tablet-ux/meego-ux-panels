/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

TileItem{
    //height: panelSize.secondaryTileHeight
    height: bpText.paintedHeight + 2*panelSize.contentTopMargin

    property alias text: bpText.text

    Text {
        id: bpText
        text: qsTr("To show items on the front of the panel select ON, to hide select OFF")
        anchors.left: parent.left
        anchors.right:  parent.right
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft

        font.pixelSize: theme_fontPixelSizeLarge
        color: panelColors.tileDescTextColor
        wrapMode: Text.Wrap
    }
}



