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

FlipPanel {
    id: container

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append("/usr/share/meego-ux-appgrid/applications/meego-app-browser.desktop")
    }

    Translator {
        catalog: "meego-ux-panels-web"
    }

    ListModel{
        id: backSettingsModel


        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.append({ "settingsTitle": qsTr("Recently visited"),
                                     "custPropName": "RecentlyVisited",
                                     "isVisible": true });
            backSettingsModel.append({ "settingsTitle": qsTr("Bookmarks"),
                                     "custPropName": "Bookmarks",
                                     "isVisible": true });
        }
    }

    //Hate to do it like this, but something changed in BrowserListModel
    //to cause rowAdded signals to apparently not come through properly,
    //and we're out of time before the release...
    //TODO: FIXME - once BrowserListModel is working properly again
    property QtObject recentpagemodel: null;
    property QtObject bookmarkmodel: null;


    Component.onCompleted: {
        reloadModels();
//model signals seem to be happening properly now from the BrowserListModel, so killing the auto-refresh
//        refreshTimer.start();
    }

    function reloadModels() {
        if (recentpagemodel != null)
            recentpagemodel.destroy();
        if (bookmarkmodel != null)
            bookmarkmodel.destroy();
        recentpagemodel = rcpComp.createObject(container);
        bookmarkmodel = bmComp.createObject(container);
    }

    Timer {
        id: refreshTimer
        //If we don't have content yet, refresh every 2 seconds, otherwise, every 5
        interval: (fpecRecentSites.count + fpecBookmarks.count == 0 ? 2000 : 5000)
        onTriggered: {
            reloadModels();
        }
        repeat: true
    }

    Component {
        id: rcpComp
        BrowserItemListModel
        {
            id:rcpModel
            type:BrowserItemListModel.ListofRecentVisited
            sortType:BrowserItemListModel.SortByDefault
        }
    }

    Component {
        id: bmComp
        BrowserItemListModel
        {
            id:bmModel
            type:BrowserItemListModel.ListofBookmarks
            sortType:BrowserItemListModel.SortByDefault
        }
    }


    front: Panel {
        id: webPanel
        panelTitle: qsTr("Web")
        panelContent: (fpecRecentSites.count + fpecBookmarks.count == 0 ? itemModelOOBE : itemModelOne)
        leftIconSource: "image://theme/panels/pnl_icn_web"
    }

    back: BackPanelStandard {
        panelTitle: qsTr("Web settings")
        settingsListModel: backSettingsModel
        isBackPanel: true
        leftIconSource: "image://theme/panels/pnl_icn_web"

        onClearHistClicked:{
           recentpagemodel.clearAllItems()
        }

    }

    resources: [
        VisualItemModel {
            id: itemModelOOBE
            Item {
                height: container.height
                width: container.width
                //anchors.left:  container.left
                //anchors.left: parent.left


                Text {
                    id: textOOBE
                    anchors.left: parent.left
                    anchors.right:  parent.right
                    anchors.top: parent.top
                    anchors.topMargin: panelSize.contentTopMargin
                    anchors.leftMargin: panelSize.contentSideMargin
                    anchors.rightMargin: panelSize.contentSideMargin
                    width: parent.width
                    text: qsTr("What's going on today? Open the browser to start using the web.")
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: panelColors.textColor
                }

                Button {
                    id: btnOOBE
                    anchors.top:  textOOBE.bottom
                    anchors.topMargin: panelSize.contentTopMargin
                    title: qsTr("Open Browser!")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        spinnerContainer.startSpinner();
                        qApp.launchDesktopByName("/usr/share/meego-ux-appgrid/applications/meego-app-browser.desktop")
                    }
                }
            }
        },

        VisualItemModel {
            id: itemModelOne

            ContextMenu {
                id: ctxMenuRecent
                property variant currentUrl
                property variant currentId
                model:[ qsTr("View"), qsTr("Hide")]

                onTriggered: {
                    if (model[index] == qsTr("View")) {
                        spinnerContainer.startSpinner();
                        recentpagemodel.viewItem(currentUrl);
                        container.notifyModel();
                    } else if (model[index] == qsTr("Hide")){
                        recentpagemodel.destroyItem(currentId)
                    } else {
                        console.log("Unhandled context action in Web: " + model[index]);
                    }
                }

            }

            ContextMenu {
                id: ctxMenuBookMark
                model:[ qsTr("View"), qsTr("Delete")]
                property variant currentUrl
                property int currentId

                onTriggered: {
                    if (model[index] == qsTr("View")) {
                        spinnerContainer.startSpinner();
                        bookmarkmodel.viewItem(currentUrl);
                        container.notifyModel();
                    } else if (model[index] == qsTr("Delete")){
                        console.log("Delete")
                        bookmarkmodel.destroyItem(currentId);
                    } else {
                        console.log("Unhandled context action in Web: " + model[index]);
                    }
                }

            }


            FrontPanelExpandableContent {
                id: fpecRecentSites
                text: qsTr("Recently visited")
                collapsible:false
                visible: backSettingsModel.get(0).isVisible && (count > 0)
                property int count: 0

                contents:FrontPanelListView{
                    height: count * (((width/16)*9)+2)
                    model: recentpagemodel
                    onCountChanged: fpecRecentSites.count = count
                    Component.onCompleted: fpecRecentSites.count = count
                    delegate:
                    FrontPanelWebPreviewItem
                    {
                        id:webPreviewItem
                        text: title
                        imageSource: thumbnailUri
                        iconSource:faviconUri
                        onClicked: {
                            spinnerContainer.startSpinner();
                            recentpagemodel.viewItem(url);
                            container.notifyModel();
                        }

                        onPressAndHold:{

                            var pos = webPreviewItem.mapToItem(scene, mouse.x, mouse.y);
                            ctxMenuRecent.currentUrl = url
                            ctxMenuRecent.currentId = id
                            ctxMenuRecent.mouseX = pos.x;
                            ctxMenuRecent.mouseY= pos.y;
                            ctxMenuRecent.visible= true
                        }

                    }
                }
            }

            FrontPanelExpandableContent {
                id: fpecBookmarks
                text: qsTr("Bookmarks")
                anchors.top:  fpecRecentSites.bottom
                visible: backSettingsModel.get(1).isVisible && (count > 0)
                property int count: 0

                contents:FrontPanelListView {
                    height: (panelSize.contentItemHeight + 2) * count
                    model:bookmarkmodel
                    onCountChanged: fpecBookmarks.count = count
                    Component.onCompleted: fpecBookmarks.count = count
                    delegate: FrontPanelIconTextItem {
                        id:bookmarkPreview
                        text: title
                        imageSource:faviconUri
                        onClicked: {
                            spinnerContainer.startSpinner();
                            bookmarkmodel.viewItem(url);
                            container.notifyModel();
                        }
                        onPressAndHold:{

                            var pos = bookmarkPreview.mapToItem(scene, mouse.x, mouse.y);
                            ctxMenuBookMark.currentUrl = url
                            ctxMenuBookMark.currentId= id
                            ctxMenuBookMark.mouseX = pos.x;
                            ctxMenuBookMark.mouseY= pos.y;
                            ctxMenuBookMark.visible= true
                        }

                    }
                }
            }
        }
    ]
}
