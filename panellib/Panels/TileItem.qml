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

PanelContent {
    id: container
    width: parent ? parent.width : 0
    contentHeight: col.height
    property alias mouseAreaActive: fpMouseArea.visible
    property bool separatorVisible: false
    default property alias contents: tileContent.sourceComponent
    property bool contentPressed: false
    property bool feedbackEnabled: true

    signal pressAndHold(variant mouse)
    signal clicked(variant mouse)

    Column {
        id: col
        width: parent.width
        Image {
            id: separator
            width: parent.width
            visible: separatorVisible
            height: separatorVisible ? sourceSize.height : 0
            source: "image://themedimage/widgets/apps/panels/panel-content-separator"
        }
        Item {
            width: parent.width
            height: panelSize.tileListSpacing
            visible: separatorVisible
        }
        Loader {
            id: tileContent
            width: parent.width
            Rectangle {
                id: fog
                z: 10
                anchors.fill: parent
                color: "white"
                opacity: 0.25
                visible: feedbackEnabled && contentPressed
            }
        }
        Item {
            width: parent.width
            height: panelSize.tileListSpacing
        }
    }
    MouseArea{
        id: fpMouseArea
        anchors.fill: parent
        visible: false
        onPressed: {
            contentPressed = true
        }
        onReleased: {
            contentPressed = false
        }
        onCanceled: {
            contentPressed = false
        }
        onPressAndHold: {
            container.pressAndHold(mouse)
        }
        onClicked: {
            container.clicked(mouse)
        }
    }
}
