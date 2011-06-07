/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

Column {
    id: col
    width: parent ? parent.width : 0
    property bool spacingVisible: false
    function display(msg) {
        notification.display(msg)
    }
    Item {
        visible: spacingVisible
        width: parent.width
        height: notification.height > 0 ? panelSize.contentAreaTopMargin : 0
        Behavior on height {PropertyAnimation {duration:100}}
    }

    InfoBar {
        id: notification
        width: parent.width
        function display(msg) {
            notification.text = msg
            notificationTimer.running = true
            notification.show()
        }
        Timer {
            id: notificationTimer
            interval: 5000
            onTriggered: {
                notification.text = ""
                notification.hide()
            }
        }
    }

    Item {
        visible: spacingVisible
        width: parent.width
        height: notification.height > 0 ? panelSize.contentAreaTopMargin : 0
        Behavior on height {PropertyAnimation {duration:100}}
    }
}
