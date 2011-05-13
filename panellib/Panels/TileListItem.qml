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
    property variant fillMode: Image.Stretch

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
            font.family: panelSize.fontFamily
            font.pixelSize: panelSize.tileFontSize
            color: panelColors.tileMainTextColor
            anchors.verticalCenter: parent.verticalCenter
            wrapMode: Text.NoWrap
        }
        Text {
            id: fpDesc
            text: fpITI.description
            width: parent.width - panelSize.tileTextLeftMargin - tileImage.width - fpText.width
            font.family: panelSize.fontFamily
            font.pixelSize: panelSize.tileFontSize
            color: panelColors.tileDescTextColor
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
    }
    resources: [
        Component {
            id: empty
            TileIcon {
                height: panelSize.tileListItemContentHeight
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
            id: normal
            TileIcon {
                height: panelSize.tileListItemContentHeight
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
