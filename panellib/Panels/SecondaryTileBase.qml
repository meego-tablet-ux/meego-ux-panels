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
    property Component imageNormal: normal
    property Component imageAlbum: album
    property Component imageChildComponent
    property alias text: fpText.text
    property alias descriptionComponent: descContent.sourceComponent
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
            id: leftMargin
            width: panelSize.tileTextLeftMargin
            height: parent.height
        }
        Column {
            width: fpITI.width - tileImage.width - leftMargin.width
            Item {
                id: topMargin
                width: 1
                height: panelSize.tileTextTopMargin
            }
            Text {
                id: fpText
                font.family: panelSize.fontFamily
                font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                color: panelColors.tileMainTextColor //THEME - VERIFY
                width: parent.width
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
            Loader {
                id: descContent
                width: parent.width
                height: fpITI.height - topMargin.height - fpText.height - bottomMargin.height
            }
            Item {
                id: bottomMargin
                width: 1
                height: panelSize.tileTextTopMargin
            }
        }
    }
    resources: [
        Component {
            id: empty
            TileIcon {
                imageSource: fpITI.imageSource
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border-empty"
                border.top: 6
                border.bottom: 6
                border.left: 6
                border.right: 6
                height: panelSize.secondaryTileContentHeight
                width: height
                fallBackImage: fpITI.fallBackImage
            }
        },
        Component {
            id: item
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fallBackImage: fpITI.fallBackImage
                fillMode: Image.Stretch
                zoomImage: true
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border-item"
                border.top: 3
                border.bottom: 3
                border.left: 3
                border.right: 3
            }
        },
        Component {
            id: album
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fillMode: Image.Stretch
                fallBackImage: fpITI.fallBackImage
                imageChild: imageChildComponent
                zoomImage: true
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border-album"
                border.top: 12
                border.bottom: 10
                border.left: 4
                border.right: 4
            }
        },
        Component {
            id: normal
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fillMode: Image.Stretch
                zoomImage: true
                fallBackImage: fpITI.fallBackImage
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://meegotheme/widgets/apps/panels/item-border"
                border.top: 6
                border.bottom: 8
                border.left: 5
                border.right: 5
            }
        }

    ]
}
