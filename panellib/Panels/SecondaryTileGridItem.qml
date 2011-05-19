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
    width: panelSize.secondaryTileContentWidth + panelSize.secondaryTileGridHSpacing
    property string imageSource
    property string imageBackground: "item"
    property bool zoomImage: false
    property bool hasImage: true
    property string fallBackImage: ""
    property variant fillMode: Image.PreserveAspectCrop

    mouseAreaActive: true

    contents: Item {
        id: tileImage
        visible: hasImage
        height: panelSize.secondaryTileContentHeight + panelSize.secondaryTileGridVSpacing
        TileIcon {
            height: panelSize.secondaryTileContentHeight
            width: panelSize.secondaryTileContentWidth
            imageSource: fpITI.imageSource
            imageBackground: fpITI.imageBackground
            fillMode: fpITI.fillMode
            zoomImage: fpITI.zoomImage
            fallBackImage: fpITI.fallBackImage
        }
    }
}
