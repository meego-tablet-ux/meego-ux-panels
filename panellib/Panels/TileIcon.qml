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
}
