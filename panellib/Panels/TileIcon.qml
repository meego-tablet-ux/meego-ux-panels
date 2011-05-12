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

    Image {
        id: fpImage
        anchors.centerIn: parent
        height: (tileIcon.zoomImage ? parent.height - parent.border.bottom - parent.border.top : sourceSize.height)
        width: (tileIcon.zoomImage ? parent.width - parent.border.right - parent.border.left : sourceSize.width)
        anchors.verticalCenterOffset: parent.border.top - parent.border.bottom
        fillMode: Image.PreserveAspectCrop
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
}
