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
    property string imageSource
    property alias imageComponent: tileImage.sourceComponent
    property Component imageEmpty: empty
    property Component imageNormal: normal
    property string text: ""
    property string description: ""
    property bool zoomImage: false
    property bool hasImage: true
    property string fallBackImage: ""

    mouseAreaActive: true

    Row {
        height: parent.height
        width: parent.width
        Loader {
            id: tileImage
            visible: hasImage
            sourceComponent: empty
            anchors.verticalCenter: parent.verticalCenter
        }
        Item {
            visible: hasImage
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Text {
            id: fpText
            text: fpITI.text + (fpITI.description && fpITI.text ? ", ":"")
            onTextChanged: {
                if (paintedWidth > parent.width - panelSize.tileTextLeftMargin - tileImage.width) {
                    elide = Text.ElideRight
                    width: parent.width - panelSize.tileTextLeftMargin - tileImage.width
                }
            }
            font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
            color: panelColors.tileMainTextColor
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.NoWrap
        }
        Text {
            id: fpDesc
            text: fpITI.description
            width: parent.width - panelSize.tileTextLeftMargin - tileImage.width - fpText.width
            font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
            color: panelColors.tileDescTextColor
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
    }
    resources: [
        Component {
            id: empty
            BorderImage {
                id: fpIconBackground
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border-empty"
                border.top: 6
                border.bottom: 6
                border.left: 6
                border.right: 6
                height: panelSize.tileListItemContentHeight
                width: height
                Image {
                    id: fpImage
                    source: fpITI.imageSource
                    anchors.centerIn: parent
                    height: (fpITI.zoomImage ? width : sourceSize.height)
                    width: (fpITI.zoomImage ? panelSize.tileListItemContentHeight - 2*parent.border.top : sourceSize.width) //THEME - VERIFY
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    Component.onCompleted: {
                        if ((fallBackImage != "") && ((fpImage.status == Image.Error))) {
                            console.log("Failed to load: " + fpITI.imageSource)
                            fpITI.imageSource = fallBackImage;
                        }
                    }
                }
            }
        },
        Component {
            id: normal
            BorderImage {
                id: fpIconBackground
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border"
                border.top: 5
                border.bottom: 7
                border.left: 4
                border.right: 4
                height: panelSize.tileListItemContentHeight
                width: height
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: fpImage
                    source: fpITI.imageSource
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: parent.height - parent.border.top - parent.border.bottom
                    width: parent.width - parent.border.left - parent.border.right
                    anchors.verticalCenterOffset: parent.border.top - parent.border.bottom
                    fillMode: Image.Stretch
                    asynchronous: true

                    Component.onCompleted: {
                        if ((fallBackImage != "") && ((fpImage.status == Image.Error))) {
                            fpImage.source = fallBackImage;
                        }
                    }
                }
            }
        }
    ]
}
