/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Content 1.0
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: fpContainer

    property variant upids: [];

    signal checkVisible()

    Translator {
        catalog: "meego-ux-panels-friends"
    }

    property Component frontComponent: ((panelManager.servicesConfigured && !panelManager.isEmpty) ? fpcNormal : fpcOOBE)

    front: SimplePanel {
        id: frontPanel
        panelTitle: qsTr("Friends")
        panelComponent: frontPanelContent
    }

    back: BackPanelGeneric {
        id: backPanel
        panelTitle: qsTr("Friends settings")
        subheaderText: qsTr("Friends panel content")
        bpContent: backPanelContent
    }

    onFlipToFront: {
        panelManager.frozen = false;
        refreshTimer.stop();
        readTimer.restart();
    }

    onFlipToBack: {
        readTimer.stop();
    }

    TopItem {
        id: topItem
        parent: fpContainer
    }

    resources: [

        Timer {
            id: refreshTimer
            interval: 30000
            onTriggered: {
                panelManager.frozen = false;
            }
        },

        Timer {
            id: readTimer
            interval: 5000
            onTriggered: {
                //console.log("fpContainer.state: ", fpContainer.state);
                if (contentLoader.amIVisible() && fpContainer.state != "back" && window.isActiveWindow)
                    fpContainer.checkVisible();
            }
        }

    ]

    Connections {
        target: allPanels
        onMovementStarted: {
            readTimer.stop();
        }
        onMovementEnded: {
            if (contentLoader.amIVisible())
                readTimer.restart();
        }
    }

    Component.onCompleted: {
        panelManager.initialize("friends");
    }

    McaPanelManager {
        id: panelManager
        categories: ["social", "im", "email", "messages"]
        servicesEnabledByDefault: true
    }


    Component {
        id: frontPanelContent
        Loader {
            id: frontPanelLoader
            sourceComponent: frontComponent
        }
    }

    Component {
        id: fpcOOBE
        Item {
            height: fpContainer.height
            width: fpContainer.width

            Text {
                id: textOOBE
                anchors.left: parent.left
                anchors.right:  parent.right
                anchors.top: parent.top
                anchors.topMargin: panelSize.contentTopMargin
                anchors.leftMargin: panelSize.contentSideMargin
                anchors.rightMargin: panelSize.contentSideMargin
                width: parent.width
                text: qsTr("You have no web accounts enabled - tap here to configure your web accounts.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: panelColors.panelHeaderColor
            }

            Button {
                id: btnOOBE
                anchors.top:  textOOBE.bottom
                anchors.topMargin: panelSize.contentTopMargin
                text: qsTr("Tap here!")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    spinnerContainer.startSpinner();
                    appsModel.launch("/usr/bin/meego-qml-launcher --opengl --app meego-ux-settings --fullscreen --cmd showPage --cdata \"Web Accounts\"")
                }
            }
        }
    }

    Component {
        id: fpcNormal

        Item {
            id: fpcNormalContent
            anchors.fill: parent

            ListView {
                id: lvContent
                model: panelManager.feedModel
                delegate: recentUpdatesDelegate
                anchors.fill: parent
                interactive: (contentHeight > height)
                cacheBuffer: panelSize.friendpanelsCacheBuffer
                snapMode: ListView.SnapToItem
                onInteractiveChanged: {
                    if (!interactive)
                        contentY = 0;
                }

                onMovementStarted:  {
                    panelManager.frozen = true;
                    refreshTimer.stop();
                    readTimer.stop();
                }

                onMovementEnded: {
                    refreshTimer.restart();
                    readTimer.restart();
                }

                onCountChanged: {
                    readTimer.restart();
                }

                Component.onCompleted: {
                    console.log(visibleArea.yPosition * height);
                }
            }


            ContextMenu {
                id: ctxMenu
                property alias ctxModel: ctxActionMenu.model
                property alias ctxPayload: ctxActionMenu.payload

                content: ActionMenu {
                    id: ctxActionMenu

                    onTriggered: {
                        panelManager.frozen = false;
                        if (model[index] == qsTr("View")) {
                            spinnerContainer.startSpinner();
                            payload[0].performStandardAction("default", payload[1]);
                        } else if (model[index] == qsTr("Hide")) {
                            payload[0].performStandardAction("hide", payload[1]);
                        } else {
                            console.log("Unhandled context action in Friends: " + model[index]);
                        }
                        ctxMenu.hide();
                    }
                }
            }

            resources: [
	        FuzzyDateTime {
		    id: fuzzyDateTime
		},

                Component {
                    id: recentUpdatesDelegate
                    PanelExpandableContent {
                        id: fiContainer
                        showHeader: false
                        property variant view: ListView.view
                        contents: FriendsItem {
                            id: friendsItemDel
                            serviceName: servicename
                            serviceIcon: serviceicon
                            authorIcon: (avatar == undefined ? "" : avatar)
                            authorName: title
                            messageText: content
                            picImage: picture ? picture : ""
                            timeStamp: fuzzyDateTime.getFuzzy(timestamp)
                            itemID: id
                            itemType: type

                            onPressAndHold: {
                                //console.log("got to onPressAndHold! Yay!" + myID);
                                if (type == "request")
                                    ctxMenu.ctxModel = [qsTr("Hide")];
                                else
                                    ctxMenu.ctxModel = [qsTr("View"), qsTr("Hide")]
                                ctxMenu.ctxPayload = [actions, myID];

                                var mousePos = friendsItemDel.mapToItem(topItem.topItem, mouse.x, mouse.y);

                                ctxMenu.setPosition(mousePos.x, mousePos.y);
                                ctxMenu.show();
                            }
                            onClicked: {
                                //console.log("got to onClicked! Yay!" + myID);
                                spinnerContainer.startSpinner();
                                actions.performStandardAction("default", myID);
                            }
                            onAcceptClicked: {
                                //console.log("Accept clicked for ID " + myID);
                                actions.performStandardAction("accept", myID);
                            }
                            onRejectClicked: {
                                //console.log("Reject clicked for ID " + myID);
                                actions.performStandardAction("reject", myID);
                            }
                            onRead: {
                                //console.log("onRead for ID " + myID);
                                actions.performStandardAction("setViewed", myID);
                            }
                        }
                    }
                }
            ]
        }
    }


    Component {
        id: backPanelContent

        Item {
            width: parent.width
            height: lvServices.height
            Column {
                id: lvServices
                width: parent.width
                BackPanelMessageTextItem {
                    id: bpMessage
                    width: parent.width
                }
                Repeater {
                    id: serviceSettings
                    model: panelManager.serviceModel
                    delegate: servicesDelegate
                }
                BackPanelClearButton {
                    onClearHistClicked: {
                        //console.log("Service settings count: " + upids.length);
                        var x;
                        for( x in upids) {
                            //console.log("Clearing history from: " + upids[x]);
                            panelManager.clearHistory(upids[x]);
                        }
                    }
                }
            }
        }
    }


    Component {
        id: servicesDelegate

        TileItem {
            id: contentDel
            separatorVisible: true
            Component.onCompleted: {
                // TODO fix this ugly workaround
                // Maybe with different api in panelmanager or panelManager.serviceModel?
                //console.log("index: " + index + " = " + upid);
                if (panelManager.isServiceEnabled(upid)) {
                    upids = upids.concat(upid);
                }
                //console.log("lenght: " + upids.length);
            }
            Item {
                height: panelSize.tileListItemContentHeight
                width: parent ? parent.width : 0
                Text {
                    id: nameText
                    anchors.left: parent.left
                    anchors.right: svcButtonLoader.left
                    anchors.rightMargin: panelSize.contentSideMargin
                    text: displayname
                    color: panelColors.tileDescTextColor //THEME - VERIFY
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: panelSize.fontFamily
                    font.pixelSize: panelSize.tileFontSize
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }

                Loader {
                    id: svcButtonLoader
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: nameText.anchors.leftMargin
                    anchors.topMargin: (anchors.rightMargin/2)  //THEME - VERIFY
                    anchors.bottomMargin: anchors.topMargin
                }

                Component {
                    id: serviceToggle

                    ToggleButton {
                        id: tbEnable
                        anchors.right: parent.right
                        on: panelManager.isServiceEnabled(upid)
                        onToggled: {
                            console.log("Setting " + name + " to " + (isOn ? "enable" : "disable"));
                            panelManager.setServiceEnabled(upid, isOn);
                        }
                    }
                }

                Component {
                    id: serviceConfigBtn
                    Button {
                        id: btnConfigure
                        anchors.right: parent.right
                        text: qsTr("Go to settings")
                        onClicked: {
                            actions.performStandardAction("configure", name);
                        }
                    }
                }

                Component.onCompleted: {
                    if (configerror) {
                        svcButtonLoader.sourceComponent = serviceConfigBtn;
                    } else {
                        svcButtonLoader.sourceComponent = serviceToggle;
                    }
                }
            }
        }
    }
}
