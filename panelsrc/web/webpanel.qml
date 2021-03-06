/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    property bool contentEmpty: (fpecRecentSites.count == 0 && fpecBookmarks.count == 0)
    property string browserDesktop: "/usr/share/applications/meego-app-browser.desktop"

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append(browserDesktop)
    }

    Translator {
        catalog: "meego-ux-panels-web"
    }

    ListModel{
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Recently visited"
            custPropName: "RecentlyVisited"
            isVisible: true
        }
        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Bookmarks"
            custPropName: "Bookmarks"
            isVisible: true
        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Recently visited"));
            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Bookmarks"));
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
        Labs.BrowserItemListModel
        {
            id: rcpModel
            type: Labs.BrowserItemListModel.ListofRecentVisited
            sortType: Labs.BrowserItemListModel.SortByDefault
        }
    }

    Component {
        id: bmComp
        Labs.BrowserItemListModel
        {
            id: bmModel
            type: Labs.BrowserItemListModel.ListofBookmarks
            sortType: Labs.BrowserItemListModel.SortByDefault
        }
    }


    front: Panel {
        id: webPanel
        panelTitle: qsTr("Web", "PanelTitle")
        panelContent: contentModel
    }

    back: BackPanelStandard {
        //: %1 is "Web" panel title
        panelTitle: qsTr("%1 settings").arg(qsTr("Web", "PanelTitle"))
        //: %1 is "Web" panel title
        subheaderText: qsTr("%1 panel content").arg(qsTr("Web", "PanelTitle"))
        settingsListModel: backSettingsModel
        isBackPanel: true
        clearButtonText: (fpecRecentSites.count == 0) ? qsTr("Visit a website") : qsTr("Clear history")

        onClearHistClicked:{
            if (fpecRecentSites.count == 0) {
                notifyModel();
                spinnerContainer.startSpinner();
                qApp.launchDesktopByName(browserDesktop)
            } else {
                clearHistoryOnFlip = true;
            }
            container.flip();
        }

    }

    resources: [
        VisualItemModel {
            id: contentModel

            PanelExpandableContent {
                id: oobe
                property bool hadContent: false
                showHeader: false
                showBackground: false
                isVisible: contentEmpty && !hadContent
                contents: PanelOobe {
                    text: qsTr("The latest websites you visit and your bookmarks will appear here.")
                    textColor: panelColors.panelHeaderColor
                    imageSource: "image://themedimage/icons/oobe/web-unavailable"
                    extraContentModel : VisualItemModel {
                        PanelButton {
                            separatorVisible: false
                            text: qsTr("Visit a website")
                            onClicked: {
                                notifyModel();
                                spinnerContainer.startSpinner();
                                qApp.launchDesktopByName(browserDesktop)
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    hadContent = !!panelObj.getCustomProp("WebHadContent")
                    if (hadContent) {
                        visible = false
                        isVisible = false
                    }
                }
                Connections {
                    target: container
                    onContentEmptyChanged: {
                        if (!contentEmpty && !oobe.hadContent) {
                            oobe.isVisible = false;
                            oobe.hadContent = true
                            panelObj.setCustomProp("WebHadContent",1)
                        }
                    }
                }
            }
            PanelExpandableContent {
                id: fpecRecentSites
                text: qsTr("Recently visited")
                isVisible: backSettingsModel.get(0).isVisible && !oobe.isVisible

                property int count: 0
                contents: Item {
                    id: recentContent
                    height: empty.height + grid.height
                    PanelOobe {
                        id: empty
                        width: parent.width
                        isVisible: !grid.isVisible
                        onIsVisibleChanged: {
                            // if we are at final height and are hidden
                            if(!isVisible && height == contentHeight) {
                                var transitionBeginHeight = empty.height
                                empty.height = 0
                                empty.visible = false
                                grid.height = transitionBeginHeight
                            }
                        }
                        text: qsTr("No recently visited websites.")
                        extraContentModel : VisualItemModel {
                            PanelButton {
                                separatorVisible: false
                                text: qsTr("Visit a website")
                                onClicked: {
                                    notifyModel();
                                    spinnerContainer.startSpinner();
                                    qApp.launchDesktopByName(browserDesktop)
                                }
                            }
                        }
                    }
                    PrimaryTileGrid {
                        id: grid
                        isVisible: fpecRecentSites.count > 0 && (!clearingHistory || fpecRecentSites.notificationVisible)
                        onHidden: {
                            if (clearingHistory) {
                                fpecRecentSites.showNotification(qsTr("You have cleared the Web history"))
                                var transitionBeginHeight = grid.height
                                grid.height = 0
                                empty.height = transitionBeginHeight
                                grid.visible = false
                                recentpagemodel.clearAllItems()
                                clearingHistory = false
                            }
                        }
                        ContextMenu {
                            id: ctxMenuRecent
                            property variant currentUrl
                            property variant currentId
                            content: ActionMenu {
                                model:[ qsTr("View"), qsTr("Hide")]

                                onTriggered: {
                                    if (model[index] == qsTr("View")) {
                                        spinnerContainer.startSpinner();
                                        recentpagemodel.viewItem(ctxMenuRecent.currentUrl);
                                        container.notifyModel();
                                    } else if (model[index] == qsTr("Hide")){
                                        recentpagemodel.destroyItem(ctxMenuRecent.currentId)
                                    } else {
                                        console.log("Unhandled context action in Web: " + model[index]);
                                    }
                                    ctxMenuRecent.hide();
                                }
                            }

                        }
                        model: recentpagemodel
                        onModelCountChanged: fpecRecentSites.count = modelCount
                        Component.onCompleted: fpecRecentSites.count = modelCount
                        delegate: PrimaryTile {
                            id:webPreviewItem
                            text: title
                            imageSource: thumbnailUri
                            //iconSource:faviconUri
                            onClicked: {
                                spinnerContainer.startSpinner();
                                recentpagemodel.viewItem(url);
                                container.notifyModel();
                            }

                            onPressAndHold:{
                                var pos = webPreviewItem.mapToItem(topItem.topItem, mouse.x, mouse.y);
                                ctxMenuRecent.currentUrl = url
                                ctxMenuRecent.currentId = id
                                ctxMenuRecent.setPosition(pos.x, pos.y);
                                ctxMenuRecent.show();
                            }

                        }
                    }
                }
            }

            PanelExpandableContent {
                id: fpecBookmarks
                text: qsTr("Bookmarks")
                anchors.top:  fpecRecentSites.bottom
                visible: backSettingsModel.get(1).isVisible && (count > 0)
                property int count: 0

                ContextMenu {
                    id: ctxMenuBookMark
                    property variant currentUrl
                    property int currentId

                    content: ActionMenu {
                        model:[ qsTr("View"), qsTr("Delete")]
                        onTriggered: {
                            if (model[index] == qsTr("View")) {
                                spinnerContainer.startSpinner();
                                bookmarkmodel.viewItem(ctxMenuBookMark.currentUrl);
                                container.notifyModel();
                            } else if (model[index] == qsTr("Delete")){
                                console.log("Delete")
                                bookmarkmodel.destroyItem(ctxMenuBookMark.currentId);
                            } else {
                                console.log("Unhandled context action in Web: " + model[index]);
                            }
                            ctxMenuBookMark.hide();
                        }
                    }
                }
                contents:PanelColumnView {
                    model:bookmarkmodel
                    onCountChanged: fpecBookmarks.count = count
                    Component.onCompleted: fpecBookmarks.count = count
                    delegate: TileListItem {
                        id:bookmarkPreview
                        separatorVisible: index > 0
                        text: title
                        imageSource:faviconUri
                        onClicked: {
                            spinnerContainer.startSpinner();
                            bookmarkmodel.viewItem(url);
                            container.notifyModel();
                        }

                        onPressAndHold:{

                            var pos = bookmarkPreview.mapToItem(window, mouse.x, mouse.y);
                            ctxMenuBookMark.currentUrl = url
                            ctxMenuBookMark.currentId= id
                            ctxMenuBookMark.setPosition(pos.x, pos.y);
                            ctxMenuBookMark.show();
                        }

                    }
                }
            }
        }
    ]
}
