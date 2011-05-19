/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
BorderImage {
    id: tileIcon

    property alias imageSource: fpImage.source
    property bool zoomImage: false
    property alias fillMode: fpImage.fillMode
    property string fallBackImage: ""
    property alias imageChild: imageChildComp.sourceComponent
    property alias imageBackground: tileIcon.state

    Image {
        id: fpImage
        property int vspace: parent.height - parent.border.bottom - parent.border.top
        property int hspace: parent.width - parent.border.right - parent.border.left
        anchors.centerIn: parent
        height: (tileIcon.zoomImage ? vspace : Math.min(vspace, sourceSize.height))
        width: (tileIcon.zoomImage ? hspace : Math.min(hspace,sourceSize.width))
        anchors.verticalCenterOffset: parent.border.top - parent.border.bottom
        fillMode: Image.PreserveAspectCrop
        clip: fillMode == Image.PreserveAspectCrop
        smooth: true
        asynchronous: true

        Component.onCompleted: {
            if ((fallBackImage != "") && ((fpImage.status == Image.Error))) {
                console.log("Failed to load: " + tileIcon.imageSource)
                tileIcon.imageSource = fallBackImage;
            }
        }
        Loader {
            id: imageChildComp
            anchors.fill: parent
        }
    }
    state: "empty"
    states: [
        State {
            name: "empty"
            PropertyChanges {
                target: tileIcon
                source: "image://themedimage/widgets/apps/panels/item-border-empty"
                border.top: 6
                border.bottom: 6
                border.left: 6
                border.right: 6
            }
        },
        State {
            name: "normal"
            PropertyChanges {
                target: tileIcon
                source: "image://themedimage/widgets/apps/panels/item-border"
                border.top: 6
                border.bottom: 8
                border.left: 5
                border.right: 5
            }
        },
        State {
            name: "album"
            PropertyChanges {
                target: tileIcon
                source: "image://themedimage/widgets/apps/panels/item-border-album"
                border.top: 12
                border.bottom: 10
                border.left: 4
                border.right: 4
            }
        },
        State {
            name: "item"
            PropertyChanges {
                target: tileIcon
                source: "image://themedimage/widgets/apps/panels/item-border-item"
                border.top: 3
                border.bottom: 3
                border.left: 3
                border.right: 3
            }
        }
    ]
}
