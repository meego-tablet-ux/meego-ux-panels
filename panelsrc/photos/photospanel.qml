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
import MeeGo.Sharing 0.1
import MeeGo.Media 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    property bool contentEmpty: recentlyViewedModel.count == 0
    property string photosDesktop: "/usr/share/applications/meego-app-photos.desktop"

    Labs.BackgroundModel {
        id: backgroundModel
    }

    Translator {
        catalog: "meego-ux-panels-photos"
    }

    //Because we do not have a universal launcher
    //Need to modify model that this app is launched
    function notifyModel()
    {
        appsModel.favorites.append(photosDesktop)
    }

    ListModel{
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Recently viewed"
            custPropName: "RecentlyViewed"
            isVisible: true
        }
        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Albums"
            custPropName: "Albums"
            isVisible: true
        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Recently viewed"));
            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Albums"));
        }
    }

    onPanelObjChanged: {
        recentlyViewedModel.hideItemsByURN(panelObj.HiddenItems)
        allAlbumsListModel.hideItemsByURN(panelObj.HiddenItems)
    }

    PhotoListModel {
        id: recentlyViewedModel
        type: PhotoListModel.ListofRecentlyViewed
        limit: 16
        sort: PhotoListModel.SortByDefault
        Component.onCompleted: {
            hideItemsByURN(panelObj.HiddenItems)
        }
    }

    PhotoListModel {
        id: allAlbumsListModel
        type: PhotoListModel.ListofUserAlbums
        limit: 0
        sort: PhotoListModel.SortByDefault
        Component.onCompleted: {
            hideItemsByURN(panelObj.HiddenItems)
        }
    }

    front: Panel {
        panelTitle: qsTr("Photos", "PanelTitle")
        panelContent: photoFront
    }

    back: BackPanelStandard {
        //: %1 is "Photos" panel title
        panelTitle: qsTr("%1 settings").arg(qsTr("Photos", "PanelTitle"))
        //: %1 is "Photos" panel title
        subheaderText: qsTr("%1 panel content").arg(qsTr("Photos", "PanelTitle"))
        settingsListModel: backSettingsModel
        isBackPanel: true
        clearButtonText: contentEmpty ? qsTr("View some photos") : qsTr("Clear history")

        onClearHistClicked: {
            if (contentEmpty) {
                notifyModel()
                spinnerContainer.startSpinner()
                qApp.launchDesktopByName(photosDesktop)
            } else {
                clearHistoryOnFlip = true
                container.flip()
            }
        }

    }

    resources: [
        VisualItemModel {
            id: photoFront

            PanelExpandableContent {
                id: oobe
                property bool hadContent: false
                isVisible: contentEmpty && fpecAlbumList.count == 0 && !hadContent
                showHeader: false
                showBackground: false
                contents: PanelOobe {
                    text: qsTr("The latest photos you view and your photo albums will appear here.")
                    textColor: panelColors.panelHeaderColor
                    imageSource: "image://themedimage/icons/oobe/photos-unavailable"
                    extraContentModel : VisualItemModel {
                        PanelButton {
                            separatorVisible: false
                            text: qsTr("View some photos")
                            onClicked: {
                                notifyModel()
                                spinnerContainer.startSpinner()
                                qApp.launchDesktopByName(photosDesktop)
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    hadContent = !!panelObj.getCustomProp("PhotosHadContent")
                    if (hadContent) {
                        visible = false
                    }
                }
                Connections {
                    target: container
                    onContentEmptyChanged: {
                        if (!contentEmpty && !oobe.hadContent) {
                            oobe.isVisible = false;
                            oobe.hadContent = true
                            panelObj.setCustomProp("PhotosHadContent",1)
                        }
                    }
                }
            }
            PanelInfoBar {
                id: infobar
                spacingVisible: true
            }

            PanelExpandableContent {
                id: fpecPhotoGrid
                text: qsTr("Recently viewed")
                isVisible: backSettingsModel.get(0).isVisible && (count > 0) && !clearingHistory
                onHidden: {
                    if(clearingHistory) {
                        infobar.display(qsTr("You have cleared the Photos history"))
                        recentlyViewedModel.clear()
                        clearingHistory = false
                    }
                }
                property int count: 0
                contents: SecondaryTileGrid{
                    model: recentlyViewedModel
                    onModelCountChanged: fpecPhotoGrid.count = modelCount
                    Component.onCompleted: fpecPhotoGrid.count = modelCount
                    delegate: SecondaryTileGridItem {
                        id:photoPreview
                        imageSource: thumburi
                        zoomImage: true
                        onClicked: {
                            spinnerContainer.startSpinner();
//                            appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showPhoto --fullscreen --app meego-app-photos --cdata " + urn )
                            qApp.launchDesktopByName(photosDesktop, "showPhoto", urn);
                            container.notifyModel();
                        }
                        //For the context Menu
                        onPressAndHold:{
                            var pos = photoPreview.mapToItem(topItem.topItem, mouse.x, mouse.y);

                            ctxMenuPhoto.currentUrn= urn
                            ctxMenuPhoto.currentUri=uri;
                            ctxMenuPhoto.menuPos = pos;
                            ctxMenuPhoto.setPosition(pos.x, pos.y);
                            ctxMenuPhoto.show();
                        }

                    }
                }
                ContextMenu {
                    id: ctxMenuPhoto
                    property string currentUrn
                    property string currentUri
                    property variant menuPos
                    content: ActionMenu {
                        model:[qsTr("Open"), qsTr("Share") ,qsTr("Hide"), qsTr("Set as background")]
                        onTriggered: {
                            if (model[index] == qsTr("Open")) {
                                spinnerContainer.startSpinner();
//                                appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showPhoto --fullscreen --app meego-app-photos --cdata " + ctxMenuPhoto.currentUrn )
                                qApp.launchDesktopByName(photosDesktop, "showPhoto", ctxMenuPhoto.currentUrn);
                                container.notifyModel()
                            } else if (model[index] == qsTr("Hide")){
                                panelObj.addHiddenItem(ctxMenuPhoto.currentUrn)
                                recentlyViewedModel.hideItemByURN(ctxMenuPhoto.currentUrn)
                            }else if (model[index] == qsTr("Share"))
                            {
                                shareObj.clearItems();
                                shareObj.addItem(ctxMenuPhoto.currentUri);
                                shareObj.shareType = MeeGoUXSharingClientQmlObj.ShareTypeImage
                                ctxMenuPhoto.hide()
                                shareObj.showContextTypes(ctxMenuPhoto.menuPos.x, ctxMenuPhoto.menuPos.y);
                            }
                            else {
                                backgroundModel.activeWallpaper = ctxMenuPhoto.currentUri;
                            }
                            ctxMenuPhoto.hide();
                        }
                    }
                }
            }

            PanelExpandableContent {
                id: fpecAlbumList
                isVisible: backSettingsModel.get(1).isVisible && !oobe.isVisible
                text: qsTr("Albums")
                property int count: 0
                contents: Item {
                    width: parent.width
                    height: empty.isVisible ? empty.height : albums.height
                    PanelOobe {
                        id: empty
                        width: parent.width
                        text: qsTr("You have no photo albums")
                        isVisible: !albums.visible
                        extraContentModel: VisualItemModel {
                            PanelButton {
                                separatorVisible: false
                                text: qsTr("Create an album")
                                onClicked: {
                                    notifyModel()
                                    spinnerContainer.startSpinner()
                                    qApp.launchDesktopByName(photosDesktop)
                                }
                            }
                        }
                    }
                    PanelColumnView {
                        id: albums
                        width: parent.width
                        model: allAlbumsListModel
                        visible: fpecAlbumList.count > 0
                        onCountChanged: fpecAlbumList.count = count
                        Component.onCompleted: fpecAlbumList.count = count
                        delegate: SecondaryTileBase {
                            id:albumPreview
                            separatorVisible: index > 0
                            imageSource: thumburi == ""? "image://themedimage/images/media/photo_thumb_default":thumburi
                            imageBackground: "normal"
                            fillMode: Image.PreserveAspectCrop
                            text: title
                            zoomImage: true
                            descriptionComponent: Item {
                                Column {
                                    width: parent.width
                                    anchors.bottom: parent.bottom
                                    Text {
                                        text: qsTr("%n photo(s)","albumphotocount", photocount).arg(photocount)
                                        width: parent.width
                                        font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                                        color: panelColors.tileDescTextColor //THEME - VERIFY
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        // TODO creationtime is empty. Use Qt.formatDateTime(t,"MMMM yyyy")
                                        // if we get creationtime as QDateTime instead of ISODate formatted string
                                        text: qsTr("Created %1").arg(""+Qt.formatDateTime(addedtime, "MMMM yyyy"))
                                        width: parent.width
                                        font.pixelSize: panelSize.tileFontSize //THEME - VERIFY
                                        color: panelColors.tileDescTextColor //THEME - VERIFY
                                        wrapMode: Text.NoWrap
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            onClicked: {
                                spinnerContainer.startSpinner();
//                                appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showAlbum --fullscreen --app meego-app-photos --cdata " + urn)
                                qApp.launchDesktopByName(photosDesktop, "showAlbum", urn);
                                container.notifyModel();
                            }

                            //For the context Menu
                            onPressAndHold:{
                                var pos = albumPreview.mapToItem(window, mouse.x, mouse.y);

                                ctxMenuAlbum.currentUrn= urn
                                ctxMenuAlbum.setPosition(pos.x, pos.y);
                                ctxMenuAlbum.show();
                            }
                        }
                    }
                }
                ContextMenu {
                    id: ctxMenuAlbum
                    property string currentUrn


                    content: ActionMenu {
                        model:[qsTr("Open"),qsTr("Hide")]

                        onTriggered: {
                            if (model[index] == qsTr("Open")) {
                                spinnerContainer.startSpinner();
//                                appsModel.launch("/usr/bin/meego-qml-launcher --opengl --cmd showAlbum --fullscreen --app meego-app-photos --cdata " + ctxMenuAlbum.currentUrn )
                                qApp.launchDesktopByName(photosDesktop, "showAlbum", ctxMenuAlbum.currentUrn);
                                container.notifyModel()
                            } else if (model[index] == qsTr("Hide")){
                                panelObj.addHiddenItem(ctxMenuAlbum.currentUrn)
                                allAlbumsListModel.hideItemByURN(ctxMenuAlbum.currentUrn)
                            } else {
                                console.log("Unhandled context action in Photos: " + model[index]);
                            }
                            ctxMenuAlbum.hide();
                        }
                    }
                }
            }
        }
    ]

}
