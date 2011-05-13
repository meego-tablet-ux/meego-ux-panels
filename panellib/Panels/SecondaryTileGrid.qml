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
    property alias emptyItemsDelegate: emptyItems.delegate
    property int gridColumns: 4
    contents: Item {
        width: parent.width
        height: col.height + 2*panelSize.primaryTileSideMargin
        Column {
            id: col
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            Grid {
                id: grid
                clip:true
                width: parent.width
                columns: gridColumns
                children: [repeater, emptyItems]
            }
        }
    }
    resources: [
        Repeater {
            id: repeater
        },
        Repeater {
            id: emptyItems
            model: (modelCount % gridColumns != 0 ) ? gridColumns - (modelCount % gridColumns) : 0
        }
    ]
}
