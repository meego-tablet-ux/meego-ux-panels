/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//TileListItem - base class for standard list items in the
//panel - this contains standard visual properties that are common


TileItem {
    id: fpITI
    height: panelSize.tileListItemHeight
    property alias imageSource: fpImage.source
    property alias backgroundImageSource: fpIconBackground.source
    property alias text: fpText.text
    property bool zoomImage: false
    property bool hasImage: true
    property string fallBackImage: ""

    mouseAreaActive: true

    Row {
        height: parent.height
        width: parent.width
        BorderImage {
            id: fpIconBackground
            visible: hasImage
            // TODO: use .sci once there is support in image provider
            // (and an .sci file)
            source: "image://meegotheme/widgets/apps/panels/item-border-empty"
            border.top: 6
            border.bottom: 6
            border.left: 6
            border.right: 6
            height: panelSize.tileListItemContentHeight
            width: panelSize.tileListItemContentHeight
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: fpImage
                anchors.centerIn: parent
                visible: true
                height: (fpITI.zoomImage ? width : sourceSize.height)
                width: (fpITI.zoomImage ? panelSize.tileListItemContentHeight : sourceSize.width) //THEME - VERIFY
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
            visible: hasImage
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Text {
            id: fpText
            width: parent.width - panelSize.tileTextLeftMargin - fpIconBackground.width
            font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
            color: panelColors.tileDescTextColor //THEME - VERIFY
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }
}
