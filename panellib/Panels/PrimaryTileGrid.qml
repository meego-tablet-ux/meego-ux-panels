/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

FrontPanelExpandableContent {
    id: container
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property alias modelCount: repeater.count
    contents: Item {
        width: parent.width
        height: childrenRect.height
        Column {
            width: parent.width
            Item {
                width: parent.width
                height: panelSize.primaryTileSideMargin
            }
            Grid {
                id: grid
                clip:true
                width: parent.width
                columns: 2
                children: repeater
            }
            Item {
                width: parent.width
                height: panelSize.primaryTileSideMargin
            }
        }
    }
    resources: [
        Repeater {
            id: repeater
        }
    ]
}
