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
    property string imageSource
    property alias imageComponent: tileImage.sourceComponent
    property Component imageEmpty: empty
    property Component imageAlbum: album
    property Component imageAlbumChild
    property alias text: fpText.text
    property alias description: fpDesc.text
    property bool zoomImage: false
    property string fallBackImage: ""

    mouseAreaActive: true

    Row {
        height: parent.height
        Loader {
            id: tileImage
            sourceComponent: empty
            anchors.verticalCenter: parent.verticalCenter
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
                height: panelSize.secondaryTileContentHeight
                width: height
                Image {
                    id: fpImage
                    source: fpITI.imageSource
                    anchors.centerIn: parent
                    height: (fpITI.zoomImage ? width : sourceSize.height)
                    width: (fpITI.zoomImage ? panelSize.secondaryTileContentHeight - 2*parent.border.top : sourceSize.width)
                    //THEME - VERIFY
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
            id: album
            BorderImage {
                id: fpIconBackground
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border-album"
                border.top: 12
                border.bottom: 10
                border.left: 4
                border.right: 4
                height: panelSize.secondaryTileContentHeight
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

                    Loader {
                        anchors.fill: parent
                        sourceComponent: fpITI.imageAlbumChild
                    }

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
