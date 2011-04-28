/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Panels 0.1

BackPanelGeneric {
    property ListModel settingsListModel
    property Component settingsListDelegate: standardSettingsDelegate


    bpContent: Item {
        ListView {
            anchors.fill: parent
            model: settingsListModel
            delegate: settingsListDelegate
            interactive: (contentHeight > height)
            flickableDirection: Flickable.VerticalFlick
        }
    }

    Component {
        id: standardSettingsDelegate
        BackPanelTextToggleItem {
            text: settingsTitle
            propName: custPropName
            onToggled: {
                settingsListModel.setProperty(index, "isVisible", isOn);
            }
        }
    }
}
