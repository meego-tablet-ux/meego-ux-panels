/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelContentItem - base class for standard content items in the
//front panel - this contains standard visual properties that are common

Item {
    width: parent ? parent.width : 0
    height: panelSize.secondaryTileHeight
    property alias contentHeight: itemBG.height
    property alias mouseAreaActive: fpMouseArea.visible
    property variant itemTop: itemTopLine
    property variant itemBottom: itemBottomLine
    property bool separatorVisible: true

    signal pressAndHold(variant mouse)
    signal clicked(variant mouse)

    Image {
        id: itemTopLine
        source: "image://themedimage/images/panels/pnl_list_top"
        width: parent.width
        height: sourceSize.height
        anchors.top: parent.top
    }

    Image {
        id: itemBG
        source: "image://themedimage/images/panels/pnl_list_bg"
        width: parent.width
        height: panelSize.contentItemHeight
        anchors.top: itemTopLine.bottom
    }

    Image {
        id: itemBottomLine
        source: "image://themedimage/images/panels/pnl_list_bottom"
        width: parent.width
        height: sourceSize.height
        anchors.top: itemBG.bottom
    }

    MouseArea{
        id: fpMouseArea
        anchors.fill: parent
        visible: false
        onPressAndHold: {
            parent.pressAndHold(mouse)
        }
        onClicked: {            
            parent.clicked(mouse)
        }
    }
}
