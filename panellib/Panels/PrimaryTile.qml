/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//SecondaryTile - base class for standard content items in the

TileItem {
    id: fpITI
    height: panelSize.primaryTileHeight
    width: panelSize.primaryTileWidth
    property alias imageSource: fpImage.source
    property alias backgroundImageSource: fpIconBackground.source
    property alias text: fpText.text
    property string fallBackImage: ""

    mouseAreaActive: true

    BorderImage {
        id: fpIconBackground
        // TODO: use .sci once there is support in image provider
        // (and an .sci file)
        source: "image://meegotheme/widgets/apps/panels/item-border"
        border.top: 6
        border.bottom: 6
        border.left: 6
        border.right: 6
        height: parent.height
        width: panelSize.primaryTileContentWidth
        anchors.verticalCenter: parent.verticalCenter
        Rectangle {
            anchors.fill: parent
            anchors.margins: 8
            anchors.bottomMargin: 12
            opacity: 0.5
            border.width: 1
        }
        Image {
            id: fpImage
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12
            height: parent.height - 16
            y: 6
            fillMode: Image.Stretch
            asynchronous: true

            Component.onCompleted: {
                if ((fallBackImage != "") && ((fpImage.status == Image.Error) || (fpImage.status == Image.Null))) {
                    fpImage.source = fallBackImage;
                }
            }
            Rectangle {
                id: shade
                width: parent.width
                height: panelSize.primaryTileTextHeight
                anchors.bottom: parent.bottom
                color: "black"
                opacity: 0.7 // THEME
            }
            Text {
                id: fpText
                anchors.bottom: parent.bottom
                anchors.top: shade.top
                anchors.left: parent.left
                anchors.leftMargin: panelSize.tileTextLeftMargin
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
                color: theme_buttonFontColor //THEME - VERIFY
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
