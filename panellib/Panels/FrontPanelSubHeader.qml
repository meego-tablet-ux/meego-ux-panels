/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelSubHeader - base class for standard headers in the
//Front panel - this contains standard visual properties that are common

Item {

    width: parent.width
    height: panelSize.contentTitleHeight

    property bool collapsed: false
    property alias text: fpSubHeaderText.text

    Text {
        id: fpSubHeaderText
        font.family: panelSize.fontFamily
        font.pixelSize: panelSize.tileFontSize
        color: panelColors.contentHeaderColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
