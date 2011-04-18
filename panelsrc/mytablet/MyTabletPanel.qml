/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Components 0.1 as Ux
import MeeGo.Settings 0.1

import MeeGo.Panels 0.1

FlipPanel {

    id: container
    property int optionClicked
    property int insertionIndex: 2


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
        visible: false
        z: 100
        parent: topItem.topItem
    }

    Ux.TopItem {
        id:  topItem
    }


    ApplicationsModel {

        id: appsModel
        directories: [ "/usr/share/meego-ux-appgrid/applications",
                       "/usr/share/applications",
                       "~/.local/share/applications" ]
    }

    property variant appsModelFavorite: appsModel.favorites


    ListModel {
        id: settingsModel

        ListElement {
            icon: "image://meegotheme/icons/settings/networks"
            type: "wifi"
            title: QT_TR_NOOP("Wi-Fi")
        }

        ListElement {
            icon: "image://meegotheme/icons/settings/sound"
            type: "sound"
            title: QT_TR_NOOP("Sound")
        }

        ListElement {
            icon: "image://meegotheme/icons/settings/everyday-settings"
            type: "launchDesktop"
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
        leftIconSource: "image://theme/panels/pnl_icn_tablet"
        panelComponent:Flickable{
            anchors.fill: parent
            interactive: (height < contentHeight)
            onInteractiveChanged: {
                if (!interactive)
                    contentY = 0;
            }

            contentHeight: myContent.height
            clip: true


            Item {
                id: myContent
                height: /*connDevSection.height +*/ topAppSection.height + settingsSection.height
                width: parent.width

/*                FrontPanelExpandableContent{
                    id: connDevSection
                    anchors.top: parent.top
                    text: qsTr("Connected devices")
                    collapsible: false
                    contents: connDevComp
                    visible: (pluggableDeviceModel.count > 0)
                }
*/

                FrontPanelExpandableContent{
                    id: topAppSection
                    anchors.top: parent.top //connDevSection.bottom
                    text: qsTr("Top applications")
                    collapsible: false
                    contents: topAppComp
                    visible: backSettingsModel.get(0).isVisible
                }

                FrontPanelExpandableContent{
                    id: settingsSection
                    anchors.top: topAppSection.bottom
                    text: qsTr("Settings")
                    collapsible: false
                    contents: settingsComp
                    visible: backSettingsModel.get(1).isVisible
                }
            }
        }

    }


    back: BackPanelStandard {
        panelTitle: qsTr("My Tablet settings")
        settingsListModel: backSettingsModel
        isBackPanel: true
        leftIconSource: "image://theme/panels/pnl_icn_tablet"

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
            height: fpGridTopApps.height +
                    fplvTopApps.height

            FrontPanelGridView{
                id:fpGridTopApps
                width: parent.width
                anchors.top: parent.top
                colCount: 3
                model: appsModelFavorite
                delegate: Item {
                    width: { return Math.floor(fpGridTopApps.width/fpGridTopApps.colCount); }
                    height: width
                    FrontPanelGridImageItem {
                        imageSource: icon
                        fallbackImageSource: "image://meegotheme/icons/launchers/meego-app-widgets"
                        width: 100
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked:{
                            spinnerContainer.startSpinner();
                            appsModel.favorites.append(filename)
                            qApp.launchDesktopByName(filename)
                        }
                    }
                }
            }


            ListView {
                id:fplvTopApps
                model:favoriteApplicationsItems
                anchors.top:fpGridTopApps.bottom
                width:parent.width
                height:contentHeight
                interactive:false
                delegate: FrontPanelIconTextItem {
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


    Component {
        id: settingsComp
        Item {
            width: parent.width
            height: lvSettings.height
            ListView {
                id: lvSettings
                width: parent.width
                height: contentHeight
                model: settingsModel
                interactive: false
                delegate: FrontPanelIconTextItem {
                    id:fpPanelIconTextItem
                    text: qsTr(title)
                    imageSource: icon
                    zoomImage: false

                    onClicked: {
                        var posInWindow = fpPanelIconTextItem.mapToItem(topItem.topItem, mouse.x, mouse.y)
                        if (type == "wifi") {
                            wifiDialog.dlgX = posInWindow.x;
                            wifiDialog.dlgY = posInWindow.y;
                            wifiDialog.visible = true;
                        } else if (type == "sound") {
                            volumeDialog.dlgX = posInWindow.x;
                            volumeDialog.dlgY = posInWindow.y - volumeDialog.height;
                            volumeDialog.visible = true;
                        } else if (type == "launchDesktop") {
                            spinnerContainer.startSpinner();
                            appsModel.favorites.append(launchName);
                            qApp.launchDesktopByName(launchName);
                        }
                    }
                }
            }
        }
    }
}

