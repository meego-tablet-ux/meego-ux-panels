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
import MeeGo.Panels 0.1

import MeeGo.Sharing 0.1
import MeeGo.Sharing.UI 0.1


Window {
    id: window
    anchors.centerIn: parent

    fullContent: true
    fullScreen: true

    Translator {
        catalog: "meego-ux-panels"
    }

    Theme {
        id: theme
    }

    //Temp to get a spinner in for UX review - BEGIN
    //Now we should be able to do "spinnerContainer.startSpinner();"

    Item {
        id: spinnerContainer
        parent: window.content
        anchors.fill: window.content
        property variant overlay: null

        TopItem {
            id: topItem
        }

        Component {
            id: spinnerOverlayComponent
            Item {
                id: spinnerOverlayInstance
                anchors.fill: parent

                Connections {
                    target: qApp
                    onWindowListUpdated: {
                        spinnerOverlayInstance.destroy();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                }
                Spinner {
                    anchors.centerIn: parent
                    spinning: true
                    onSpinningChanged: {
                        if (!spinning)
                        {
                            spinnerOverlayInstance.destroy()
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    // eat all mouse events
                }
            }
        }

        function startSpinner() {
            if (overlay == null)
            {
                overlay = spinnerOverlayComponent.createObject(spinnerContainer);
                overlay.parent = topItem.topItem;
            }
        }
    }

    //Temp to get a spinner in for UX review - END

    //onStatusBarTriggered: orientation = (orientation +1)%4;

    PanelProxyModel {
        id: panelsModel
        filterType: PanelProxyModel.FilterTypeHidden
        sortType: PanelProxyModel.SortTypeIndex
    }

    Labs.ApplicationsModel {
        id: appsModel
        directories: [ "/usr/share/meego-ux-appgrid/applications", "/usr/share/applications", "~/.local/share/applications" ]
    }

    Labs.WindowModel {
        id: windowModel
    }

    Loader {
        id: appSwitcherLoader
    }

    Image {
        opacity: 0
        source: "image://themedimage/widgets/apps/panels/panel-background"
        width: sourceSize.width
        height: sourceSize.height
        asynchronous: false
        onStatusChanged: {
            if ((status == Image.Ready) && visible) {
                panelSize.baseSize = width;
                source = "";
                visible = false;
            }
        }
    }

    Item {
        id: panelSize
        property int baseSize: 0
        property int oneHalf: Math.round(baseSize/2)
        property int oneThird: Math.round(baseSize/3)
        property int oneFourth: Math.round(baseSize/4)
        property int oneSixth: Math.round(baseSize/6)
        property int oneEigth: Math.round(baseSize/8)
        property int oneTenth: Math.round(baseSize/10)
        property int oneTwentieth: Math.round(baseSize/20)
        property int oneTwentyFifth: Math.round(baseSize/25)
        property int oneThirtieth: Math.round(baseSize/30)
        property int oneSixtieth: Math.round(baseSize/60)
        property int oneEightieth: Math.round(baseSize/80)
        property int oneHundredth: Math.round(baseSize/100)

        property int panelOuterSpacing: oneTwentieth

        property int contentSideMargin: 12
        property int contentTopMargin: 8
        property int contentTitleHeight: 56
        property int contentAreaTopMargin: 3
        property int contentAreaBottomMargin: 6
        property int contentAreaSideMargin: 10
        property int primaryTileContentHeight: 138
        property int primaryTileGridVSpacing: 2
        property int primaryTileContentWidth: 214
        property int primaryTileGridHSpacing: 6
        property int primaryTileTextHeight: 36
        property int secondaryTileHeight: 110
        property int secondaryTileContentHeight: 108
        property int secondaryTileGridVSpacing: 2
        property int secondaryTileContentWidth: 104
        property int secondaryTileGridHSpacing: 6
        property int secondaryTileGridSideMargin: 7
        property int tileTextLeftMargin: 15
        property int tileTextTopMargin: 15
        property int tileTextLineSpacing: 2
        property int tileListItemHeight: 63
        property int tileListItemContentHeight: 49
        property int serviceIconSize: 40
        property int tileFontSize: theme.fontPixelSizeNormal
        property string fontFamily: theme.fontFamily
        property int timestampFontSize: theme.fontPixelSizeSmall
    }

    Item {
        id: panelColors
        property string panelHeaderColor: theme.buttonFontColor
        property string contentHeaderColor: theme.fontColorNormal
        property string tileMainTextColor: "#2a7e98"
        property string tileDescTextColor: "#666666"
    }

    overlayItem: Item {
        id: deviceScreen        
        anchors.fill: parent

        clip: true

        ShareObj {
            id: shareObj
        }

        Rectangle {
            id: background
            anchors.fill: parent
            color: "black"
            property variant backgroundImage: null
            Labs.BackgroundModel {
                id: backgroundModel
                Component.onCompleted: {
                    background.backgroundImage = backgroundImageComponent.createObject(background);
                }
                onActiveWallpaperChanged: {
                    background.backgroundImage.destroy();
                    background.backgroundImage = backgroundImageComponent.createObject(background);       
                }
            }
            Component {
                id: backgroundImageComponent
                Image {
                    //anchors.centerIn: parent
                    anchors.fill: parent
                    asynchronous: true
                    source: backgroundModel.activeWallpaper
                    sourceSize.height: background.height
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        StatusBar {
            anchors.top: parent.top
            width: parent.width
            height: theme.statusBarHeight
            active: window.isActiveWindow
            backgroundOpacity: theme.panelStatusBarOpacity
        }

        Item {
            id: panelsContainer
            anchors.fill: parent
            anchors.topMargin: theme.statusBarHeight

                ListView {
                    id: allPanels
                    anchors.topMargin: panelSize.panelOuterSpacing
                    anchors.fill: parent
                    interactive: true
                    cacheBuffer: count * panelSize.baseSize
                    flickableDirection: Flickable.HorizontalFlick
                    orientation: ListView.Horizontal
                    snapMode: ListView.NoSnap
                    spacing: panelSize.panelOuterSpacing
                    property bool animationEnabled: true
                    onMovementEnded: {
                        snapMode = ListView.NoSnap
                    }
                    onMovementStarted: {
                        snapMode = ListView.SnapToItem
                    }
                    Behavior on contentX {
                        NumberAnimation { duration: 250 }
                    }
                    model:panelsModel
                    delegate: Loader {
                        id: contentLoader
                        source: path

                        height: parent.height
                        //width: 640
                        property QtObject aPanelObj: panelObj
                        property string aDisplayName: displayName
                        property int aIndex: index

                        function amIVisible() {
                            //console.log("amIVisiblePanel")
                            var minX = panelsContainerFlickable.visibleArea.xPosition * panelsContainerFlickable.contentWidth;
                            var maxX = minX + panelsContainerFlickable.width;
                            var myMinX = index * (item.width + panelSize.panelOuterSpacing);
                            var myMaxX = ((index+1) * (item.width + panelSize.panelOuterSpacing))-panelSize.panelOuterSpacing;
                            //console.log("amIVisiblePanel? minX: ", minX, "maxX: ", maxX);
                            //console.log("amIVisiblePanel? idx: ", index, "displayName: ", displayName, "myMinX: ", myMinX, "myMaxX: ", myMaxX);
                            if ((myMinX < minX) || (myMaxX > maxX)) {
                                //console.log("amIVisiblePanel? false");
                                return false;
                            }
                            //console.log("amIVisiblePanel? true");
                            return true;
                        }

                        Component.onCompleted: {
                            console.log("displayName: " + displayName + ", index: " + index)
                        }

                        Behavior on opacity {
                            NumberAnimation { duration:250 }
                        }

                        Behavior on x {
                            id:moveSlowly
                            enabled: allPanels.animationEnabled 
                            NumberAnimation { duration: 250}
                        }

                        Behavior on width {
                            NumberAnimation { duration:250 }
                        }

                        onOpacityChanged: {
                            if (opacity == 0) {
                            panelsModel.remove(index)
//                                    panelsContainerFlickable.contentWidth
//                                    = panelsContainerFlickable.contentWidth -(item.width + panelView.spacing)
                            }

                        }

                        Connections {
                            target: contentLoader.item
                            onVisibleOptionClicked:{
                                if (allowHide) {
                                    panelObj.IsVisible = false;
                                }
                            }
                            onFlipped: {
                                // Calculate contentX change by hand because Behavior doesn't work when
                                // using positionViewAtIndex. Assumes that all panels are same width. Is that safe?
                                //allPanels.positionViewAtIndex(index, ListView.Contain);
                                var start = allPanels.contentX;
                                var end = start + allPanels.width
                                var panelStartsAt = index*(width + allPanels.spacing);
                                var panelEndsAt = index*(width + allPanels.spacing) + width;
                                //console.log("area: "+start+" - "+ end);
                                //console.log("panelStarts at: "+panelStartsAt+", panelEnds at: "+ panelEndsAt);
                                if (start > panelStartsAt) {
                                    allPanels.contentX = panelStartsAt;
                                } else if (end < panelEndsAt){
                                    allPanels.contentX = start + (panelEndsAt - end);
                                }
                            }

                            onDraggingFinished:{
                                console.log("------------oldIdx: " + oldIndex + ", newIdx: " + newIndex)
                                panelsModel.move(oldIndex, newIndex)
                            } //onDraggingFinished
                        }
                    } //Delegate - panel loader
                }
        }
    }
}

