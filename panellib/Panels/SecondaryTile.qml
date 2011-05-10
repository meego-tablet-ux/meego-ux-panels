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
    height: panelSize.secondaryTileHeight
    property alias imageSource: fpImage.source
    property alias backgroundImageSource: fpIconBackground.source
    property alias text: fpText.text
    property alias description: fpDesc.text
    property bool zoomImage: false
    property string fallBackImage: ""

    mouseAreaActive: true

    Row {
        height: parent.height
        BorderImage {
            id: fpIconBackground
            // TODO: use .sci once there is support in image provider
            // (and an .sci file)
            source: "image://meegotheme/widgets/apps/panels/item-border-empty"
            border.top: 6
            border.bottom: 6
            border.left: 6
            border.right: 6
            height: panelSize.secondaryTileContentHeight
            width: height
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: fpImage
                anchors.centerIn: parent
                height: (fpITI.zoomImage ? width : sourceSize.height)
                width: (fpITI.zoomImage ? panelSize.contentIconSize : sourceSize.width) //THEME - VERIFY
                fillMode: Image.PreserveAspectCrop
                asynchronous: true

                Component.onCompleted: {
                    if ((fallBackImage != "") && ((fpImage.status == Image.Error) || (fpImage.status == Image.Null))) {
                        fpImage.source = fallBackImage;
                    }
                }
            }
        }

        Item {
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Column {
            Item {
                width: 1
                height: panelSize.tileTextTopMargin
            }
            Text {
                id: fpText
                font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
                color: panelColors.tileMainTextColor //THEME - VERIFY
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
            Item {
                width: 1
                height: panelSize.tileTextLineSpacing
            }
            Text {
                id: fpDesc
                font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
                color: panelColors.tileDescTextColor //THEME - VERIFY
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
