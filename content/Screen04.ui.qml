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
    id: fourthUseCase
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
}
