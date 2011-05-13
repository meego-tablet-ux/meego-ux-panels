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
    height: panelSize.secondaryTileGridItemHeight
    width: panelSize.secondaryTileGridItemWidth
    property alias imageSource: fpIconBackground.imageSource
    property alias backgroundImageSource: fpIconBackground.source
    property alias fallBackImage: fpIconBackground.fallBackImage

    mouseAreaActive: true

    TileIcon {
        id: fpIconBackground
        height: panelSize.secondaryTileContentWidth
        width: height
        zoomImage: true
        fillMode: Image.Stretch
        // TODO: use .sci once there is support in image provider
        // (and an .sci file)
        source: "image://themedimage/widgets/apps/panels/item-border-item"
        border.top: 3
        border.bottom: 3
        border.left: 3
        border.right: 3
    }
}
