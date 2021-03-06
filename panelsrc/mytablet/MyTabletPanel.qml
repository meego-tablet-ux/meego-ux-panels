/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1 as Labs
import MeeGo.Components 0.1
import MeeGo.Settings 0.1

import MeeGo.Panels 0.1

FlipPanel {

    id: container
    property int optionClicked
    property int insertionIndex: 2
    property bool appStoreReady: false
    property int topAppsCount: 0

    Translator {
        catalog: "meego-ux-panels-mytablet"
    }

    VolumeDialog {
        id: volumeDialog
        visible: false
        z: 100
        parent: topItem.topItem
    }

    WifiDialog {
        id: wifiDialog
        z: 100
        parent: topItem.topItem
    }

    property variant appsModelFavorite: appsModel.favorites
    property variant appsModelFeatured: appsModel.appupFeatured
    property variant appsModelUpdated: appsModel.appupUpdated


    ListModel {
        id: settingsModel

        ListElement {
            icon: "image://themedimage/icons/settings/networks"
            type: "wifi"
            title: QT_TR_NOOP("Wi-Fi")
        }

        ListElement {
            icon: "image://themedimage/icons/settings/sound"
            type: "sound"
            title: QT_TR_NOOP("Sound")
        }

        ListElement {
            icon: "image://themedimage/icons/settings/everyday-settings"
            type: "allSettings"
            title: QT_TR_NOOP("All settings")
            launchName: "/usr/share/applications/meego-ux-settings.desktop"
        }
    }

/*  //2011-04-04, JEA: We don't have anything we can do with USB devices right now, so removing the functionality for the moment
    UDiskDeviceModel {
        id: pluggableDeviceModel
    }
*/


    ListModel{
        id: favoriteApplicationsItems

        ListElement {
            title: QT_TR_NOOP("View all applications")
            actionType:"javaScript"
            action:"qApp.showGrid()"
        }

    }

    ListModel {
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Top applications"
            custPropName: "TopApps"
            isVisible: true
        }

//        ListElement {
//            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
//            settingsTitle: "Featured applications"
//            custPropName: "FeaturedApps"
//            isVisible: true
//        }

//        ListElement {
//            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
//            settingsTitle: "Updated applications"
//            custPropName: "UpdatedApps"
//            isVisible: true
//        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Top applications"));
//            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Featured applications"));
//            backSettingsModel.setProperty(2, "settingsTitle", qsTr("Updated applications"));
        }
    }

    Component.onCompleted: {
        console.log("My Tablet onCompleted, haveAppStore: " + qApp.haveAppStore);
        if (qApp.haveAppStore) {
            favoriteApplicationsItems.append({ "title": QT_TR_NOOP("Visit the Intel AppUp(sm) center"),
                                             "actionType": "appStore" });
            backSettingsModel.append({ "settingsTitle": qsTr("Featured applications"),
                                     "custPropName": "FeaturedApps",
                                     "isVisible": true});
            backSettingsModel.append({ "settingsTitle": qsTr("Updated applications"),
                                     "custPropName": "UpdatedApps",
                                     "isVisible": true});
            container.appStoreReady = true;
        }
    }

    front: Panel {

        panelTitle: qsTr("My Tablet", "PanelTitle")
        panelContent: myContents
    }

    resources: [
        VisualItemModel {
            id: myContents
/*            PanelExpandableContent{
                id: connDevSection
                anchors.top: parent.top
                text: qsTr("Connected devices")
                contents: connDevComp
                visible: (pluggableDeviceModel.count > 0)
            }
*/
            PanelExpandableContent {
                id: oobe
                showHeader: false
                showBackground: false
                height: 200
                isVisible: (topAppsCount == 0)
                contents: PanelOobe {
                    id: topAppsOobe
                    width: parent.width
                    text: qsTr("The applications you use most will appear here. Discover the apps already in your tablet, or visit Intel AppUp to download more.")
                    textColor: panelColors.panelHeaderColor
                    imageSource: "image://themedimage/icons/oobe/apps-unavailable"
                }
            }
            PanelExpandableContent{
                id: topAppSection
                text: qsTr("Top applications")
                showHeader: !oobe.isVisible
                contents: topAppComp
                isVisible: backSettingsModel.get(0).isVisible
                // onIsVisibleChanged: {
                //     container.flip();
                // }
            }

            PanelExpandableContent {
                id: appupFeaturedSection
                text: qsTr("Featured applications")
                contents: featuredAppsComp
                isVisible: (container.appStoreReady && backSettingsModel.get(1).isVisible && appsModelFeatured.count)
            }

            PanelExpandableContent {
                id: appupUpdatedSection
                text: qsTr("Updated applications")
                contents: updatedAppsComp
                isVisible: (container.appStoreReady && backSettingsModel.get(2).isVisible && appsModelUpdated.count)
            }

            PanelExpandableContent{
                id: settingsSection
                text: qsTr("Settings")
                contents: settingsComp
            }
        }
    ]



    back: BackPanelStandard {
        //: %1 is "My Tablet" panel title
        panelTitle: qsTr("%1 settings").arg(qsTr("My Tablet", "PanelTitle"))
        //: %1 is "My Tablet" panel title
        subheaderText: qsTr("%1 content").arg(qsTr("My Tablet", "PanelTitle"))
        settingsListModel: backSettingsModel
        isBackPanel: true

        clearButtonVisible:false
    }



/*    Component {
        id: connDevComp

         FrontPanelListView{
                id:fpListViewconDev
                model:pluggableDeviceModel
		width: parent.width
		height: ((panelSize.contentItemHeight+2) * count)
                delegate:FrontPanelIconTextItem{
                    text:deviceLabel
                }

            }

    }
*/

    Component {
        id: topAppComp
        Item {
            height: topAppsGrid.height +
                    fplvTopApps.height
            SecondaryTileGrid {
                id: topAppsGrid
                width: parent.width
                anchors.top: parent.top
                isVisible: modelCount > 0
                onModelCountChanged: {
                    topAppsCount = modelCount;
                }
                Component.onCompleted: {
                    topAppsCount = modelCount;
                }
                model: appsModelFavorite
                delegate: SecondaryTileGridItem {
                    imageBackground: "empty"
                    imageSource: icon
                    fallBackImage: "image://themedimage/icons/launchers/meego-app-widgets"
                    onClicked:{
                        spinnerContainer.startSpinner();
                        appsModel.favorites.append(filename)
                        qApp.launchDesktopByName(filename)
                    }
                }
            }
            Column {
                id:fplvTopApps
                anchors.top:topAppsGrid.bottom
                width:parent.width
                Repeater {
                    model:favoriteApplicationsItems
                    delegate: TileListItem {
                        separatorVisible: topAppsGrid.visible || index > 0
                        hasImage: false
                        text: qsTr(title)
                        onClicked: {
                            spinnerContainer.startSpinner();
                            if( actionType == "javaScript" )
                                eval(action)
                            else if ( actionType == "launchDesktop")
                            {
                                appsModel.favorites.append(action);
                                qApp.launchDesktopByName(action);
                            } else if (actionType == "appStore") {
                                qApp.showAppStore();
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: featuredAppsComp
        PanelColumnView {
            id:fpFeaturedApps
            width: parent.width
            anchors.top: parent.top
            model: appsModelFeatured
            delegate: SecondaryTile {
                width: fpFeaturedApps.width
                separatorVisible: index > 0
                imageSource: icon
                text: title
                description: comment
                fallBackImage: "image://themedimage/icons/launchers/meego-app-widgets"
                onClicked:{
                    spinnerContainer.startSpinner();
                    //appsModel.favorites.append(filename)
                    appsModel.launch(exec);
                }
                Component.onCompleted: {
                    console.log("featured app C.oC, title, icon:", title, icon);
                }
            }
        }
    }

    Component {
        id: updatedAppsComp
        PanelColumnView {
            id:fpUpdatedApps
            width: parent.width
            anchors.top: parent.top
            model: appsModelUpdated
            delegate: SecondaryTile {
                width: fpUpdatedApps.width
                separatorVisible: index > 0
                imageSource: icon
                text: title
                description: comment
                fallBackImage: "image://themedimage/icons/launchers/meego-app-widgets"
                onClicked:{
                    spinnerContainer.startSpinner();
                    //appsModel.favorites.append(filename)
                    appsModel.launch(exec);
                }
                Component.onCompleted: {
                    console.log("updated app C.oC, title, icon:", title, icon);
                }
            }
        }
    }

    Component {
        id: settingsComp
        PanelColumnView {
            width: parent.width
            model: settingsModel
            delegate: TileListItem {
                id:fpPanelIconTextItem
                description: qsTr(title)
                imageSource: icon
                separatorVisible: index > 0
                zoomImage: false
                onClicked: {
                    var posInWindow = fpPanelIconTextItem.mapToItem(topItem.topItem, mouse.x, mouse.y)
                    if (type == "wifi") {
                        wifiDialog.setPosition(posInWindow.x, posInWindow.y);
                        wifiDialog.show();
                    } else if (type == "sound") {
                        volumeDialog.dlgX = posInWindow.x;
			var volume_dglY=posInWindow.y - volumeDialog.height;
			volumeDialog.dlgY = volume_dglY>0?volume_dglY:posInWindow.y;
                        volumeDialog.visible = true;
                    } else if (type == "allSettings") {
                        spinnerContainer.startSpinner();
                        appsModel.favorites.append(launchName);
                        qApp.launchDesktopByName(launchName, "showPage", "settings");
//                        appsModel.launch("meego-qml-launcher --fullscreen --opengl --app meego-ux-settings --cmd showPage --cdata settings")
                    }
                }
            }
        }
    }
}

