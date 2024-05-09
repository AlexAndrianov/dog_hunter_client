/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts

Rectangle {
    id: secondUseCase
    width: 400
    height: 800
    anchors.fill: parent
    enabled: true

    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    MouseArea {
        id: dragArea2
        anchors.fill: parent
        drag.target: secondUseCase // Set the target to the whole screen
        drag.axis: Drag.YAxis // Allow dragging in both X and Y directions
    }

    ColumnLayout {
        anchors.fill: parent

        Button {
            id: buttonMD
            width: 150
            text: "My Dogs"
            font.pointSize: 20
            Layout.margins: 33
            Layout.fillWidth: true
            enabled: true
            background: Rectangle {
                color: "lightgray"
                radius: 5
            }
        }

        Button {
            id: buttonSWE
            width: 150
            text: "Search the walk events"
            font.pointSize: 20
            Layout.margins: 33
            Layout.fillWidth: true
            enabled: true
            background: Rectangle {
                color: "lightgray"
                radius: 5
            }
        }

        Button {
            id: buttonIWE
            width: 150
            text: "Introduce the walk event"
            font.pointSize: 20
            Layout.margins: 33
            Layout.fillWidth: true
            enabled: true
            background: Rectangle {
                color: "lightgray"
                radius: 5
            }
        }

        Button {
            id: buttonFb
            width: 150
            text: "Feedbacks"
            font.pointSize: 20
            Layout.margins: 33
            Layout.fillWidth: true
            enabled: true
            background: Rectangle {
                color: "lightgray"
                radius: 5
            }
        }
    }

    states: [
        State {
            name: "clicked"
        }
    ]

    Connections {
        target: buttonMD
        onClicked: function() {
        }
    }

    Connections {
        target: buttonSWE
        onClicked: function() {
            var page3 = Qt.createComponent("Screen03.ui.qml");
             if (page3.status === Component.Ready) {
                 page3.createObject(changer);
            }
        }
    }

    Connections {
        target: buttonIWE
        onClicked: function() {
        }
    }

    Connections {
        target: buttonFb
        onClicked: function() {
        }
    }
}
