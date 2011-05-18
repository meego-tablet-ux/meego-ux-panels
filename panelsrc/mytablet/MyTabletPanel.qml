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

    Item {
        id: privateData
        property int topApplicationsLimit: 8
    }

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

    TopItem {
        id:  topItem
    }

    property variant appsModelFavorite: appsModel.favorites


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
            launchName: "/usr/share/meego-ux-appgrid/applications/meego-ux-settings.desktop"
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

    Component.onCompleted: {
        console.log("My Tablet onCompleted, haveAppStore: " + qApp.haveAppStore);
        if (qApp.haveAppStore)
            favoriteApplicationsItems.append({ "title": qsTr("Visit the Intel AppUp(sm) center"),
                                             "actionType": "appStore" });
    }

    ListModel {
        id: backSettingsModel

        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Top applications"
            custPropName: "TopApps"
            isVisible: true
        }
        ListElement {
            //i18n OK, as it gets properly set in the Component.onCompleted - long drama why this is necessary - limitation in QML translation capabilities
            settingsTitle: "Settings"
            custPropName: "Settings"
            isVisible: true
        }

        //Get around i18n issues w/ the qsTr of the strings being in a different file
        Component.onCompleted: {
            backSettingsModel.setProperty(0, "settingsTitle", qsTr("Top applications"));
            backSettingsModel.setProperty(1, "settingsTitle", qsTr("Settings"));
        }
    }

    front: SimplePanel {

        panelTitle: qsTr("My Tablet")
        panelComponent: Flickable {
            anchors.fill: parent
            interactive: (height < contentHeight)
            onInteractiveChanged: {
                if (!interactive)
                    contentY = 0;
            }

            contentHeight: myContent.height

            Item {
                id: myContent
                height: /*connDevSection.height +*/ topAppSection.height + settingsSection.height
                width: parent.width

/*                PanelExpandableContent{
                    id: connDevSection
                    anchors.top: parent.top
                    text: qsTr("Connected devices")
                    contents: connDevComp
                    visible: (pluggableDeviceModel.count > 0)
                }
*/

                // Loader {
                //     id: topAppSection
                //     anchors.top: parent.top //connDevSection.bottom
                //     sourceComponent: topAppComp
                //     visible: backSettingsModel.get(0).isVisible
                // }
                PanelExpandableContent{
                    id: topAppSection
                    anchors.top: parent.top //connDevSection.bottom
                    text: qsTr("Top applications")
                    contents: topAppComp
                    visible: backSettingsModel.get(0).isVisible
                }

                PanelExpandableContent{
                    id: settingsSection
                    anchors.top: topAppSection.bottom
                    text: qsTr("Settings")
                    contents: settingsComp
                    visible: backSettingsModel.get(1).isVisible
                }
            }
        }

    }


    back: BackPanelStandard {
        panelTitle: qsTr("My Tablet settings")
        subheaderText: qsTr("My Tablet content")
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
            width:parent.width
            height: fpListTopApps.height +
                    fplvTopApps.height

            SecondaryTileGrid {
                id:fpListTopApps
                width: parent.width
                anchors.top: parent.top
                model: appsModelFavorite
                delegate: SecondaryTileGridItem {
                    visible: index < privateData.topApplicationsLimit
                    imageComponent: imageEmpty
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
                anchors.top:fpListTopApps.bottom
                width:parent.width
                Repeater {
                    model:favoriteApplicationsItems
                    delegate: TileListItem {
                        separatorVisible: true
                        hasImage: false
                        text: title
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
                        volumeDialog.dlgY = posInWindow.y - volumeDialog.height;
                        volumeDialog.visible = true;
                    } else if (type == "allSettings") {
                        spinnerContainer.startSpinner();
                        appsModel.favorites.append(launchName);
                        appsModel.launch("meego-qml-launcher --fullscreen --opengl --app meego-ux-settings --cmd showPage --cdata settings")
                    }
                }
            }
        }
    }
}

