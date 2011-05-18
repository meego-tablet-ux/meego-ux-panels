/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

TileItem {
    id: fpITI
    height: panelSize.secondaryTileContentHeight + panelSize.secondaryTileGridVSpacing
    width: panelSize.secondaryTileContentWidth + panelSize.secondaryTileGridHSpacing
    property string imageSource
    property alias imageComponent: tileImage.sourceComponent
    property Component imageEmpty: empty
    property Component imageNormal: normal
    property bool zoomImage: false
    property bool hasImage: true
    property string fallBackImage: ""
    property variant fillMode: Image.PreserveAspectCrop

    mouseAreaActive: true

    Loader {
        id: tileImage
        visible: hasImage
        sourceComponent: item
        anchors.verticalCenter: parent.verticalCenter
    }
    resources: [
        Component {
            id: empty
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fillMode: fpITI.fillMode
                zoomImage: fpITI.zoomImage
                fallBackImage: fpITI.fallBackImage
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://themedimage/widgets/apps/panels/item-border-empty"
                border.top: 3
                border.bottom: 3
                border.left: 3
                border.right: 3
            }
        },
        Component {
            id: item
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fillMode: fpITI.fillMode
                zoomImage: fpITI.zoomImage
                fallBackImage: fpITI.fallBackImage
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://themedimage/widgets/apps/panels/item-border-item"
                border.top: 3
                border.bottom: 3
                border.left: 3
                border.right: 3
            }
        },
        Component {
            id: normal
            TileIcon {
                height: panelSize.secondaryTileContentHeight
                width: height
                imageSource: fpITI.imageSource
                fillMode: fpITI.fillMode
                zoomImage: fpITI.zoomImage
                fallBackImage: fpITI.fallBackImage
                // TODO: use .sci once there is support in image provider
                // (and an .sci file)
                source: "image://themedimage/widgets/apps/panels/item-border"
                border.top: 5
                border.bottom: 7
                border.left: 4
                border.right: 4
            }
        }
    ]
}
