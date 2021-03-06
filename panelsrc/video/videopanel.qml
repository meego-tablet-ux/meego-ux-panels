/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Sharing 0.1
import MeeGo.Media 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    property bool contentEmpty: (recentlyViewed.count == 0)
    property string videoDesktop: "/usr/share/applications/meego-app-video.desktop"

    Translator {
        catalog: "meego-ux-panels-video"
    }

    //Currently no hidable sections, as we only have 1 section in video for the moment,
    //but leaving this here as a placehold for when there's more...
    ListModel{
        id: backSettingsModel
        //Get around i18n issues w/ the qsTr of the strings being in a different file
//        Component.onCompleted: {
//            backSettingsModel.append({ "settingsTitle": qsTr("Recently watched"),
//                                     "custPropName": "RecentlyWatched",
//                                     "isVisible": true });
//        }

    }

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append(videoDesktop)
    }


    VideoListModel {
        id: recentlyViewed
        type: VideoListModel.ListofRecentlyViewed
        limit: 4
        sort: VideoListModel.SortByDefault
        Component.onCompleted: {
            hideItemsByURN(panelObj.HiddenItems)
        }
    }

    onPanelObjChanged: {
        recentlyViewed.hideItemsByURN(panelObj.HiddenItems)
    }

    front: Panel {
        panelTitle: qsTr("Video", "PanelTitle")
        panelContent: videoFront
    }

    back: BackPanelStandard {
        //: %1 is "Video" panel title
        panelTitle: qsTr("%1 settings").arg(qsTr("Video", "PanelTitle"))
        //: %1 is "Video" panel title
        subheaderText: qsTr("%1 panel content").arg(qsTr("Video", "PanelTitle"))
        settingsListModel: backSettingsModel
        isBackPanel: true
        clearButtonText: contentEmpty ? qsTr("Watch a video") : qsTr("Clear history")

        onClearHistClicked:{
            if (contentEmpty) {
                notifyModel();
                spinnerContainer.startSpinner();
                qApp.launchDesktopByName(videoDesktop)
            } else {
                clearHistoryOnFlip = true;
            }
            container.flip();
        }

    }

    resources: [
        VisualItemModel {
            id: videoFront
            PanelExpandableContent {
                id: oobe
                property bool hadContent: false
                isVisible: contentEmpty && !hadContent
                showHeader: false
                showBackground: false
                contents: PanelOobe {
                    text: qsTr("The latest videos you watch will appear here.")
                    textColor: panelColors.panelHeaderColor
                    imageSource: "image://themedimage/icons/oobe/video-unavailable"
                    extraContentModel : VisualItemModel {
                        PanelButton {
                            separatorVisible: false
                            text: qsTr("Watch a video")
                            onClicked: {
                                notifyModel();
                                spinnerContainer.startSpinner();
                                qApp.launchDesktopByName(videoDesktop)
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    hadContent = !!panelObj.getCustomProp("VideosHadContent")
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
                            panelObj.setCustomProp("VideosHadContent",1)
                        }
                    }
                }
            }
            PanelExpandableContent {
                id: empty
                isVisible: !myContent.visible && !oobe.visible
                showHeader: false
                showBackground: false
                contents: PanelOobe {
                    text: qsTr("No recently watched videos.")
                    textColor: panelColors.panelHeaderColor
                    extraContentModel : VisualItemModel {
                        PanelButton {
                            separatorVisible: false
                            text: qsTr("Watch a video")
                            onClicked: {
                                notifyModel();
                                spinnerContainer.startSpinner();
                                qApp.launchDesktopByName(videoDesktop)
                            }
                        }
                    }
                }
            }
            PanelExpandableContent {
                id: myContent
                showHeader: false
                isVisible: !contentEmpty && !clearingHistory
                onHidden: {
                    if(clearingHistory) {
                         empty.showNotification(qsTr("You have cleared the Video history"))
                         recentlyViewed.clear()
                         clearingHistory = false
                    }
                }
                contents: PrimaryTileGrid {
                    ContextMenu {
                        id: ctxMenu
                        property string currentUrn
                        property string currentUri
                        property variant menuPos

                        content: ActionMenu {
                            model:[ qsTr("Play"),qsTr("Share"), qsTr("Hide")]


                            onTriggered: {
                                if (model[index] == qsTr("Play")) {
                                    spinnerContainer.startSpinner();
//                                    appsModel.launch( "/usr/bin/meego-qml-launcher --opengl --cmd playVideo --app meego-app-video --fullscreen --cdata " + ctxMenu.currentUrn )
                                    qApp.launchDesktopByName(videoDesktop, "playVideo", ctxMenu.currentUrn);
                                    container.notifyModel()
                                } else if (model[index] == qsTr("Hide")){
                                    panelObj.addHiddenItem(ctxMenu.currentUrn)
                                    recentlyViewed.hideItemByURN(ctxMenu.currentUrn)
                                }
                                else if (model[index] == qsTr("Share"))
                                {
                                    shareObj.clearItems();
                                    shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeVideo
                                    shareObj.addItem(ctxMenu.currentUri);
                                    ctxMenu.hide()
                                    shareObj.showContextTypes(ctxMenu.menuPos.x, ctxMenu.menuPos.y);
                                }
                                else {
                                    console.log("Unhandled context action in Photos: " + model[index]);
                                }
                                ctxMenu.hide();
                            }
                        }

                    }
                    model: recentlyViewed
                    delegate: PrimaryTile {
                        id:previewItem
                        imageSource:thumburi
                        text: title

                        onClicked: {
                            spinnerContainer.startSpinner();
//                            appsModel.launch( "/usr/bin/meego-qml-launcher --opengl --cmd playVideo --app meego-app-video --fullscreen --cdata " + urn )
                            qApp.launchDesktopByName(videoDesktop, "playVideo", urn);
                            container.notifyModel()
                        }

                                //For the context Menu
                        onPressAndHold:{

                            var pos = previewItem.mapToItem(window, mouse.x, mouse.y);
                            ctxMenu.currentUrn=urn;
                            ctxMenu.currentUri=uri;
                            ctxMenu.menuPos = pos;
                            ctxMenu.setPosition(pos.x, pos.y);
                            ctxMenu.show();

                        }
                    }
                }
            }
        }
    ]
}
