/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

//TileItem - base class for standard content items in the
//panel - this contains standard visual properties that are common

Item {
    id: container
    width: parent.width
    property alias mouseAreaActive: fpMouseArea.visible
    property bool separatorVisible: false
    property alias content: tileContent.sourceComponent

    signal pressAndHold(variant mouse)
    signal clicked(variant mouse)

    Column {
        width: parent.width
        Image {
            width: parent.width
            id: separator
            visible: separatorVisible
            height: separatorVisible ? sourceSize.height : 0
            source: "image://meegotheme/widgets/apps/panels/panel-content-separator"
        }
        Loader {
            id: tileContent
        }
    }
    MouseArea{
        id: fpMouseArea
        anchors.fill: parent
        visible: false
        onPressAndHold: {
            container.pressAndHold(mouse)
        }
        onClicked: {
            container.clicked(mouse)
        }
    }
}
