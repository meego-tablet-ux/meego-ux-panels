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

    property bool clearHistoryOnFlip: false
    property bool clearingHistory: false
    property bool oobeVisible: true
    property int enabledServicesCount: 0

    signal checkVisible()

    Translator {
        catalog: "meego-ux-panels-friends"
    }

    property bool contentEmpty: true
    property bool initialized: panelManager.servicesConfigured

    front: SimplePanel {
        id: frontPanel
        panelTitle: qsTr("Friends")
        panelComponent: fpcContent
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
    onFlipComplete: {
        if (clearHistoryOnFlip) {
            clearHistoryOnFlip = false;
            clearingHistoryTimer.running = true
        }
    }
    Timer {
        id: clearingHistoryTimer
        interval: 300
        onTriggered: {
            clearingHistory = true
        }
    }

    Connections {
        target: window
        onIsActiveWindowChanged: {
            panelManager.frozen = false;
            refreshTimer.stop();
            if (window.isActiveWindow)
                readTimer.restart();
            else
                readTimer.stop();
        }
    }

    function servicesListChanged() {
        var upids = panelManager.servicesList;
        // console.log("Feed list count: " + upids.length);
        // console.log("Feed list: " + upids);
        var x;
        var enabledCount = 0;
        for( x in upids) {
            if (panelManager.isServiceEnabled(upids[x])) {
                enabledCount = enabledCount + 1;
            }
        }
        fpContainer.enabledServicesCount = enabledCount;
    }

    function clearHistory() {
        var upids = panelManager.servicesList
        // console.log("Feed list count: " + upids.length);
        // console.log("Feed list: " + upids);
        var x;
        for( x in upids) {
            if (panelManager.isServiceEnabled(upids[x])) {
                console.log("Clearing history from: " + upids[x]);
                panelManager.clearHistory(upids[x]);
            }
        }
        // console.log("clearHistory done!")
    }

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
        onIsEmptyChanged: {
            contentEmpty = isEmpty
        }
        onServicesListChanged: {
            console.log("onServicesListChanged: " + serviceList)
            fpContainer.servicesListChanged()
        }
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
        },
        Component {
            id: fpcContent
        Item {
            width: parent.width
            height: parent.height
            PanelExpandableContent {
                id: oobe
                showHeader: false
                isVisible: contentEmpty && !hadContent
                showBackground: false
                property bool hadContent: false
                contents: PanelOobe {
                    text: qsTr("Emails, instant messages and social network updates will appear here.")
                    textColor: panelColors.panelHeaderColor
                    imageSource: "image://themedimage/icons/launchers/meego-app-browser"
                    extraContentModel: setupButtonsModel
                    extraContentDelegate: setupButtonsDelegate
                }
                Component.onCompleted: {
                    hadContent = panelObj.getCustomProp("FriendsHadContent")
                    if (hadContent) {
                        visible = false
                        isVisible = false
                    }
                    oobeVisible = isVisible
                }
                onIsVisibleChanged: {
                    oobeVisible = isVisible
                }
                Connections {
                    target: fpContainer
                    onContentEmptyChanged: {
                        if (!contentEmpty && !oobe.hadContent) {
                            oobe.isVisible = false;
                            oobeVisible = false
                            oobe.hadContent = true
                            panelObj.setCustomProp("FriendsHadContent",1)
                        }
                    }
                }
            }
            PanelExpandableContent {
                id: empty
                isVisible: !lvContent.visible && !oobe.visible && enabledServicesCount > 0
                showHeader: false
                showBackground: false
                contents: PanelOobe {
                    text: qsTr("No recent updates from friends.")
                    textColor: panelColors.panelHeaderColor
                }
            }
            PanelExpandableContent {
                id: noServices
                isVisible: !lvContent.visible && !oobe.visible && enabledServicesCount == 0
                showHeader: false
                showBackground: false
                contents: PanelOobe {
                    text: qsTr("You have turned off all your accounts.")
                    textColor: panelColors.panelHeaderColor
                    extraContentModel : VisualItemModel {
                        PanelButton {
                            separatorVisible: false
                            text: qsTr("Turn accounts on")
                            onClicked: {
                                fpContainer.flip();
                            }
                        }
                    }
                }
            }
            ListView {
                id: lvContent
                model: panelManager.feedModel
                visible: initialized && !contentEmpty
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
                        clip: true
                        showHeader: false
                        property variant view: ListView.view
                        isVisible: !clearingHistory
                        onHidden: {
                            if(clearingHistory) {
                                empty.showNotification(qsTr("You have cleared the Friends history"))
                                clearHistory()
                                clearingHistory = false
                            }
                        }
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
    ]

    ListModel {
        id: setupButtonsModel
        ListElement {
            title: QT_TR_NOOP("Set up your email")
            page: "Email"
        }
        ListElement {
            title: QT_TR_NOOP("Set up your instant messaging")
            page: "IM"
        }
        ListElement {
            title: QT_TR_NOOP("Sign in to a social network")
            page: "\"Web Accounts\""
        }
    }
    Component {
        id: setupButtonsDelegate
        PanelButton {
            separatorVisible: false
            text: qsTr(title)
            onClicked: {
                spinnerContainer.startSpinner()
                appsModel.launch("meego-qml-launcher --fullscreen --opengl --app meego-ux-settings --cmd showPage --cdata "+page)
            }
        }
    }

    Component {
        id: backPanelContent

        Item {
            width: parent.width
            height: lvServices.height
            Connections {
                target: fpContainer
                onOobeVisibleChanged: {
                    lvServices.setSettingsModel()
                }
            }
            Component.onCompleted: {
                lvServices.setSettingsModel()
            }
            Column {
                id: lvServices
                function setSettingsModel() {
                    serviceSettings.model = undefined;
                    if (!oobeVisible) {
                        serviceSettings.delegate = servicesDelegate;
                        serviceSettings.model = panelManager.serviceModel;
                    } else {
                        serviceSettings.delegate = setupButtonsDelegate;
                        serviceSettings.model = setupButtonsModel;
                    }
                }
                width: parent.width
                BackPanelMessageTextItem {
                    id: bpMessage
                    width: parent.width
                }
                Repeater {
                    id: serviceSettings
                }
                PanelButton {
                    visible: !contentEmpty
                    text: qsTr("Clear history")
                    onClicked: {
                        clearHistoryOnFlip = true;
                        fpContainer.flip();
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
                        active: true
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
