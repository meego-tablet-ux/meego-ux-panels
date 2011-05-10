/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//FrontPanelIconTextItem - base class for standard content items in the
//Front panel - this contains standard visual properties that are common


FrontPanelContentItem {
    id: fpITI
    property alias imageSource: fpImage.source
    property alias backgroundImageSource: fpIconBackground.source
    property alias text: fpText.text
    property bool zoomImage: false
    property string fallBackImage: ""

    contentHeight: panelSize.contentItemHeight
    mouseAreaActive: true

    Image {
        id: fpIconBackground
        source: "image://meegotheme/widgets/apps/panels/item-border-empty"
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

    Text {
        id: fpText
        font.pixelSize: theme.fontPixelSizeLarge //THEME - VERIFY
        color: panelColors.textColor //THEME - VERIFY
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: (((fpIconBackground.status == Image.Null) || (fpIconBackground.status == Image.Error)) ? parent.left : fpIconBackground.right)
        anchors.leftMargin: ((fpIconBackground.status == Image.Null) || (fpIconBackground.status == Image.Error)) ? panelSize.contentSideMargin : (fpIconBackground.width/4)
        anchors.right: parent.right
        anchors.rightMargin: fpIconBackground.anchors.leftMargin
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
