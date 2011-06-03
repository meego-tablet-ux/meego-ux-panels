/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

Item {
    id: fpec

    width: parent ? parent.width : 0

    property bool isVisible: true
    property int animationDuration: panelAnimationsEnabled ?  contentAnimationDuration : 0

    signal hidden()

    property alias text: fpSubHeaderText.text
    property alias contents: fpContents.sourceComponent
    property alias showHeader: fpsubheader.visible
    property alias showBackground: background.visible

    property bool notificationVisible: notification.height == 0

    function showNotification(text) {
        notification.display(text)
    }

    BorderImage {
        id: background
        anchors.fill: parent
        // TODO: use .sci once there is support in image provider
        source: showHeader ? "image://themedimage/widgets/apps/panels/panel-content-background" :
                             "image://themedimage/widgets/apps/panels/panel-content-background-no-header"
        border.top: 55
        border.bottom: 8
        border.left: 8
        border.right: 8
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2*panelSize.contentAreaSideMargin

        Item {
            id:fpsubheader
            width: parent.width
            height: panelSize.contentTitleHeight
            z:1

            Text {
                id: fpSubHeaderText
                font.family: panelSize.fontFamily
                font.pixelSize: panelSize.tileFontSize
                color: panelColors.contentHeaderColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                smooth: true
            }
        }
        Item {
            id: topMargin
            width: parent.width
            height: panelSize.contentAreaTopMargin
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
            id: fpContentsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            height: fpContents.height
        Loader{
            id:fpContents
            height: item ? item.height : 0
            z:fpsubheader.z-1

            anchors.left: parent.left
            anchors.right: parent.right
            //clip: true
        }
        }
        Item {
            id: bottomMargin
            width: parent.width
            height: panelSize.contentAreaBottomMargin
        }
    }
    states: [
        State {
            name: "visible"
            when: fpec.isVisible
            PropertyChanges {
                target: fpec
                opacity: 1
                height: (showHeader ? fpsubheader.height : 0 ) + notification.height + fpContentsContainer.height + topMargin.height + bottomMargin.height
            }
        },
        State {
            name: "hidden"
            when: !fpec.isVisible
            PropertyChanges {
                target: fpec
                opacity: 0
                height: 0
            }
        }
    ]

    transitions: [
        Transition {
            to: "hidden"
            SequentialAnimation {
                PropertyAnimation {
                    properties: "opacity"
                    duration: animationDuration
                }
                ScriptAction {script: {fpec.visible = false; fpec.hidden()}}
                PropertyAnimation {
                    properties: "height"
                    duration: animationDuration
                }
            }
        },
        Transition {
            to: "visible"
            SequentialAnimation {
                PropertyAnimation {
                    properties: "height"
                    duration: animationDuration
                }
                ScriptAction {script: fpec.visible = true}
                PropertyAnimation {
                    properties: "opacity"
                    duration: animationDuration
                }
            }
        }
    ]

}
