/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//PrimaryTile - base class for standard content items in the

TileItem {
    id: fpITI
    height: panelSize.primaryTileHeight
    width: panelSize.primaryTileWidth
    property alias imageSource: fpIconBackground.imageSource
    property alias backgroundImageSource: fpIconBackground.source
    property string text
    property alias fallBackImage: fpIconBackground.fallBackImage

    mouseAreaActive: true

    TileIcon {
        id: fpIconBackground
        height: parent.height
        width: panelSize.primaryTileContentWidth
        fillMode: Image.Stretch
        zoomImage: true
        // TODO: use .sci once there is support in image provider
        // (and an .sci file)
        source: "image://themedimage/widgets/apps/panels/item-border"
        border.top: 6
        border.bottom: 8
        border.left: 6
        border.right: 6
        anchors.verticalCenter: parent.verticalCenter
        imageChild: Item {
            anchors.fill: parent
            Rectangle {
                id: shade
                visible: fpText.visible
                width: parent.width
                height: panelSize.primaryTileTextHeight
                anchors.bottom: parent.bottom
                color: "black"
                opacity: 0.7 // THEME
            }
            Text {
                id: fpText
                visible: text
                text: fpITI.text
                anchors.bottom: parent.bottom
                anchors.top: shade.top
                anchors.left: parent.left
                anchors.leftMargin: panelSize.tileTextLeftMargin
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                font.family: panelSize.fontFamily
                font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                color: theme.buttonFontColor //THEME - VERIFY
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
