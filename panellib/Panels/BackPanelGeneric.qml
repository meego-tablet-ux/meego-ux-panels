/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Panels 0.1


SimplePanel {
    id: backPanelGeneric

    signal clearHistClicked(variant btnPos)

    property Component bpContent
    property bool clearButtonVisible :true

    isBackPanel: true

    panelComponent: backPanel

    Component {
        id: backPanel
        Item {
            id: bpComp
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left:  parent.left

            BackPanelMessageTextItem
            {
                id: bpMessage
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
            }

            BackPanelIconTextItem {
                id: bpManagePanels
                imageSource: "image://meegotheme/icons/settings/everyday-settings"
                text: qsTr("Manage panels")
                onClicked: {
                    spinnerContainer.startSpinner();
                    appsModel.launch("meego-qml-launcher --opengl --app meego-ux-settings --cmd showPage --cdata Panels --fullscreen")
                }
                anchors.top: bpMessage.bottom
            }

            BackPanelIconTextItem {
                visible: panelObj.AllowHide
                id: bpHidePanel
                imageSource: ""
                text: qsTr("Hide panel")
                onClicked: {
                    panelObj.IsVisible = false;
                }
                anchors.top: bpManagePanels.bottom
            }

            Loader {
                id:bpContentLoader
                width: parent.width
                anchors.top: (panelObj.AllowHide ? bpHidePanel.bottom : bpManagePanels.bottom)
                anchors.bottom: bpClearButton.visible? bpClearButton.top : parent.bottom
                anchors.bottomMargin: (bpClearButton.visible ? panelSize.contentTopMargin : 0)
                anchors.left: parent.left
                sourceComponent: bpContent
            }

            Button {
                id : bpClearButton
                visible:backPanelGeneric.clearButtonVisible
                title: qsTr("Clear history")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: panelSize.contentTopMargin
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    var btnXY = topItem.topItem.mapFromItem(bpComp,
                                                            (x+(width/2)),
                                                            y);
                    backPanelGeneric.clearHistClicked(btnXY)
                }
            }
        }
    }
}

