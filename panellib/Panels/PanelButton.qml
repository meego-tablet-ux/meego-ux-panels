/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

TileItem {
    id: container
    separatorVisible: true
    width: parent ? parent.width : 0

    property string text: ""

    signal clicked()

    contents: Item {
        height: button.height + 2*panelSize.contentTopMargin
        Button {
            id: button
            active: true
            text: container.text
            font.family: panelSize.fontFamily
            font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
            width: parent.width - 2*panelSize.contentSideMargin
            maxWidth: width
            anchors.bottomMargin: panelSize.contentTopMargin
            anchors.topMargin: panelSize.contentTopMargin
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                container.clicked()
            }
        }
    }
}
