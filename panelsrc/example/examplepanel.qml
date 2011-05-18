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
            settingsTitle: QT_TR_NOOP("Example setting 1")
            custPropName: QT_TR_NOOP("ExampleSetting1")
            isVisible: true
        }
        ListElement {
            settingsTitle: QT_TR_NOOP("Example setting 2")
            custPropName: QT_TR_NOOP("ExampleSetting2")
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
    }

    front: Panel {
        id: examplePanel
        panelTitle: qsTr("Example")
        panelContent: contents
    }

    back: BackPanelStandard {
        panelTitle: qsTr("Example settings")
        subheaderText: qsTr("Example panel content")
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
            contents: PrimaryTileGrid {
                model: exampleModel
                delegate: PrimaryTile {
                    text: title
                    imageSource: image
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
            contents: SecondaryTileGrid {
                model: exampleModel
                delegate: SecondaryTileGridItem {
                    imageSource: image
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
            contents: PanelColumnView {
                model: exampleModel
                delegate: SecondaryTile {
                    separatorVisible: index > 0
                    text: title
                    description: desc
                    imageSource: image
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
            contents: PanelColumnView {
                model: exampleModel
                delegate: TileListItem {
                    separatorVisible: index > 0
                    text: title
                    description: desc
                    imageSource: image
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
