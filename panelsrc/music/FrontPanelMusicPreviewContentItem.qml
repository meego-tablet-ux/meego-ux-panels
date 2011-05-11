/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

SecondaryTile {
    id: fpMusicPreview

    property bool imagePlayStatus: false

    property bool isCurrentlyPlayingLayout: false
    signal backButtonClicked()
    signal playButtonClicked()
    signal forwardButtonClicked()

    mouseAreaActive: true
    zoomImage: true
    fallBackImage: "image://theme/media/music_thumb_med"
    imageComponent: imageAlbum
    imageAlbumChild: playPauseComponent
    Component {
        id: playPauseComponent
        Image{
            id: playPauseButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            // TODO: get right size images
            height: parent ? parent.height : 0
            width: width
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: imagePlayStatus?"image://themedimage/images/panels/pnl_btn_pause_up"
            :"image://themedimage/images/panels/pnl_btn_play_up"
            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    var posInItem = fpMusicPreview.mapFromItem(playPauseButton, mouse.x, mouse.y);
                    fpMusicPreview.pressAndHold(posInItem);
                }
                onClicked: {
                    fpMusicPreview.playButtonClicked();
                }
            }
        }
    }
}
