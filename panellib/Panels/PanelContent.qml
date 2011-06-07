/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: content
    property bool isVisible: true
    property int animationDuration: panelAnimationsEnabled ?  contentAnimationDuration : 0
    property int hiddenHeight: 0
    property int contentHeight: 0

    Component.onCompleted: {
        if (isVisible) {
            height = contentHeight
            opacity = 1
        } else {
            height = hiddenHeight
            opacity = 0.0001
        }
    }
    onIsVisibleChanged: {
        if (isVisible) {
            content.show()
        } else {
            content.hide()
        }
    }

    function show() {
        hideAnimation.stop()
        showAnimation.start()
    }
    function hide() {
        showAnimation.stop()
        hideAnimation.start()
    }
    onContentHeightChanged: {
        if (isVisible) {
            height = contentHeight;
        }
    }

    signal shown()
    signal hidden()

    SequentialAnimation {
        id: hideAnimation
        PropertyAnimation {
            target: content
            property: "opacity"
            to: 0.00001
            duration: animationDuration
        }
        ScriptAction {script: {content.hidden()}}
        PropertyAnimation {
            target: content
            property: "height"
            to: hiddenHeight
            duration: animationDuration
        }
        ScriptAction {script: {content.visible = false; }}
    }
    SequentialAnimation {
        id: showAnimation
        ScriptAction {script: content.visible = true}
        PropertyAnimation {
            target: content
            property: "height"
            to: contentHeight
            duration: animationDuration
        }
        PropertyAnimation {
            target: content
            property: "opacity"
            to: 1
            duration: animationDuration
        }
        ScriptAction {script: {content.shown();height = contentHeight;}}
    }


    // states: [
    //     State {
    //         name: "visible"
    //         when: content.isVisible
    //         PropertyChanges {
    //             target: content
    //             opacity: 1
    //             height: contentHeight
    //         }
    //     },
    //     State {
    //         name: "hidden"
    //         when: !content.isVisible
    //         PropertyChanges {
    //             target: content
    //             opacity: 0.00001
    //             height: hiddenHeight
    //         }
    //     }
    // ]

    // transitions: [
    //     Transition {
    //         to: "hidden"
    //         SequentialAnimation {
    //             PauseAnimation {duration: 300}
    //             PropertyAnimation {
    //                 properties: "opacity"
    //                 duration: animationDuration
    //             }
    //             ScriptAction {script: {content.hidden()}}
    //             PropertyAnimation {
    //                 properties: "height"
    //                 duration: animationDuration
    //             }
    //             ScriptAction {script: {content.visible = false; }}
    //         }
    //     },
    //     Transition {
    //         to: "visible"
    //         SequentialAnimation {
    //             ScriptAction {script: content.visible = true}
    //             PropertyAnimation {
    //                 properties: "height"
    //                 duration: animationDuration
    //             }
    //             PropertyAnimation {
    //                 properties: "opacity"
    //                 duration: animationDuration
    //             }
    //             ScriptAction {script: {content.shown()}}
    //         }
    //     }
    // ]

}
