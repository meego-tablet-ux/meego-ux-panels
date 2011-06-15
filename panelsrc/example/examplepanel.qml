/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1
import MeeGo.Components 0.1

FlipPanel {
    id: container

    Translator {
        catalog: "meego-ux-panels-example"
    }

    ListModel{
        id: backSettingsModel

        ListElement {
            settingsTitle: QT_TR_NOOP("Primary grid")
            custPropName: QT_TR_NOOP("PrimaryGrid")
            isVisible: true
        }
        ListElement {
            settingsTitle: QT_TR_NOOP("Secondary grid")
            custPropName: QT_TR_NOOP("SecondaryGrid")
            isVisible: true
        }
        ListElement {
            settingsTitle: QT_TR_NOOP("Secondary list")
            custPropName: QT_TR_NOOP("SecondaryList")
            isVisible: true
        }
        ListElement {
            settingsTitle: QT_TR_NOOP("ListItem list")
            custPropName: QT_TR_NOOP("ListItemList")
            isVisible: true
        }

    }
    ListModel {
        id: exampleModel
        ListElement {
            title: "Title 1"
            desc: "Description 1"
            image: ""
        }
        ListElement {
            title: "Title 2"
            desc: "Description 3"
            image: ""
        }
        ListElement {
            title: "Title 3"
            desc: "Description 3"
            image: ""
        }
        ListElement {
            title: "Title 4"
            desc: "Description 4"
            image: ""
        }
        ListElement {
            title: "Title 5"
            desc: "Description 5"
            image: ""
        }
    }

    front: Panel {
        id: examplePanel
        panelTitle: qsTr("Example", "PanelTitle")
        panelContent: contents
    }

    back: BackPanelStandard {
        //: %1 is "Example" panel title
        panelTitle: qsTr("%1 settings").arg(qsTr("Example", "PanelTitle"))
        //: %1 is "Example" panel title
        subheaderText: qsTr("%1 panel content").arg(qsTr("Example", "PanelTitle"))
        settingsListModel: backSettingsModel

        onClearHistClicked:{
           console.log("Clear history clicked!");
        }

    }
    VisualItemModel {
        id: contents
        PanelExpandableContent {
            id: primaryGrid
            text: qsTr("Primary grid")
            visible: backSettingsModel.get(0).isVisible
            contents: PrimaryTileGrid {
                model: exampleModel
                delegate: PrimaryTile {
                    text: title
                    imageSource: image
                    imageBackground: "normal"
                    onClicked: {
                        console.log("Item clicked: " + title);
                    }
                    onPressAndHold:{
                        console.log("Item pressAndHold: " + title);
                    }
                }
            }
        }
        PanelExpandableContent {
            id: secondaryGrid
            text: qsTr("Secondary grid")
            visible: backSettingsModel.get(1).isVisible
            contents: SecondaryTileGrid {
                model: exampleModel
                delegate: SecondaryTileGridItem {
                    imageSource: image
                    imageBackground: "item"
                    onClicked: {
                        console.log("Item clicked: " + title);
                    }

                    onPressAndHold:{
                        console.log("Item pressAndHold: " + title);
                    }
                }
            }
        }
        PanelExpandableContent {
            id: secondaryList
            text: qsTr("Secondary list")
            visible: backSettingsModel.get(2).isVisible
            contents: PanelColumnView {
                model: exampleModel
                delegate: SecondaryTile {
                    separatorVisible: index > 0
                    text: title
                    description: desc
                    imageSource: image
                    imageBackground: "normal"
                    onClicked: {
                        console.log("Item clicked: " + title);
                    }

                    onPressAndHold:{
                        console.log("Item pressAndHold: " + title);
                    }
                }
            }
        }
        PanelExpandableContent {
            id: listItemList
            text: qsTr("ListItem list")
            visible: backSettingsModel.get(3).isVisible
            contents: PanelColumnView {
                model: exampleModel
                delegate: TileListItem {
                    separatorVisible: index > 0
                    text: title
                    description: desc
                    imageSource: image
                    imageBackground: "item"
                    onClicked: {
                        console.log("Item clicked: " + title);
                    }

                    onPressAndHold:{
                        console.log("Item pressAndHold: " + title);
                    }
                }
            }
        }
    }
}
