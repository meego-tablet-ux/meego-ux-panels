/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

// SimplePanel.qml
//
// The most simple version of a panel that expects a Component to be assigned
// to the panelComponent property - everything to do with the content is up to you!

Item {
    id: simplePanel

    property alias panelTitle: titleText.text

    property bool isBackPanel: false
    property Component panelComponent //Set this to a Component with the contents

    // These signals are bound to FlipPanel's flip state change
    signal titleClicked
    signal titlePressAndHold
    signal wheelIconPressed
    signal rightIconClicked
    signal released

    width: panelBG.width + panelDSL.width + panelDSR.width
    height: parent.height
    anchors.top: parent.top
    anchors.bottom: parent.bottom


    Item {
        id: panelHeader
        anchors.top: parent.top
        height: titleImg.height
        width:  titleImg.width
        anchors.horizontalCenter: parent.horizontalCenter
        z: parent.z+1
        Image {
            id: titleImg
            anchors.top: parent.top
            anchors.left: parent.left
            height: sourceSize.height
            width: sourceSize.width
            source: "image://meegotheme/widgets/apps/panels/panel-header-" + panelObj.UniqueName

            onStatusChanged: {
                if (status == Image.Error) {
                    //If we can't load the colored titlebar, fall back to default
                    source = "image://meegotheme/widgets/apps/panels/panel-header"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: simplePanel.titleClicked()
                onPressAndHold: simplePanel.titlePressAndHold()
            }

            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: panelColors.textColor
                font.pixelSize: theme.fontPixelSizeLarge
                text: panelTitle
            }

            Image {
               id:rightIcon
               anchors.rightMargin: panelSize.contentSideMargin
               anchors.right: parent.right
               anchors.verticalCenter: parent.verticalCenter
               source: "image://meegotheme/widgets/apps/panels/flip-panel"
               width: sourceSize.width
               height: sourceSize.height

               MouseArea {
                   anchors.fill: parent
                   onPressed: {
                       rightIcon.source = "image://meegotheme/widgets/apps/panels/flip-panel-active"
                       var mappedMouse = simplePanel.parent.mapFromItem(rightIcon, mouse.x, mouse.y)
                       simplePanel.rightIconPressed(mappedMouse)
                   }
                   onPositionChanged:{
                       var mappedMouse = simplePanel.parent.mapFromItem(rightIcon, mouse.x, mouse.y)
                       simplePanel.rightIconPositionChanged(mappedMouse)
                   }

                   onReleased: {
                       rightIcon.source = "image://meegotheme/widgets/apps/panels/flip-panel"
                       var mappedMouse = simplePanel.parent.mapFromItem(rightIcon, mouse.x, mouse.y)
                       simplePanel.rightIconReleased(mappedMouse)
                   }

                   onClicked: simplePanel.rightIconClicked()
               }
            }
        }
    }
    Image {
        id: fpTitleDropShadow
        source: "image://themedimage/images/panels/pnl_titlebar_shadow"
        width: panelHeader.width
        anchors.top: panelHeader.bottom
        z: panelHeader.z
    }

    Image {
        id: panelDSL
        source: "image://themedimage/images/panels/pnl_shadow_left"
        width: sourceSize.width
        height: parent.height
        anchors.left: parent.left
        anchors.top: panelHeader.bottom
        anchors.bottom: parent.bottom
        fillMode: Image.TileVertically
    }

    Image {
        id: panelBG
        source: "image://themedimage/images/panels/pnl_bg" + (isBackPanel ? "_setting" : "")
        width: sourceSize.width
        anchors.left:  panelDSL.right
        height: parent.height
        anchors.bottom: parent.bottom
        anchors.top: panelHeader.top
        anchors.topMargin: 6

    }

    Loader {
        id: contentLoader
        sourceComponent: panelComponent
        width: panelBG.width
        anchors.left: panelBG.left
        anchors.top: panelHeader.bottom
        anchors.bottom: parent.bottom
    }

    Image {
        id: panelDSR
        source: "image://themedimage/images/panels/pnl_shadow_right"
        width: sourceSize.width
        height: parent.height
        anchors.left: panelBG.right
        anchors.top: panelHeader.bottom
        anchors.bottom: parent.bottom
        fillMode: Image.TileVertically
    }
}
