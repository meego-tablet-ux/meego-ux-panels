/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

FrontPanelColumnView {

    id: fpMusicTrackListView
    width: parent.width
    delegate: trackComponent

    Component {
        id: trackComponent

        FrontPanelContentItem {
            width: parent.width
            contentHeight: panelSize.contentItemHeight

            Image{
                id: imgArt
                anchors.left: parent.left
                sourceSize.height: panelSize.contentItemHeight
                sourceSize.width: sourceSize.height
                source: thumburi

                Component.onCompleted: {
                    if ((imgArt.status == Image.Error) || (imgArt.status == Image.Null)) {
                        imgArt.source = "image://theme/media/music_thumb_med";
                    }
                }
            }

            Text {
                id: fpMainText
                text: title
                font.pixelSize: theme_fontPixelSizeLarge //THEME - VERIFY
                color: panelColors.textColor
                anchors.top: parent.top
                anchors.topMargin: font.pixelSize/2
                anchors.left: imgArt.right
                anchors.leftMargin: panelSize.contentSideMargin
                anchors.right: parent.right
                anchors.rightMargin: panelSize.contentSideMargin
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
