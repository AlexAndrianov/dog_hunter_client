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
    id: firstUsesCase
    width: 400
    height: 800
    anchors.fill: parent

    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: firstUsesCase // Set the target to the whole screen
        drag.axis: Drag.YAxis // Allow dragging in both X and Y directions
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent

        Text {
            id: text1
            text: qsTr("The Dog Hunter")
            anchors.topMargin: 10
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            font.bold: true
        }

        // Username input field
        TextInput {
            id: usernameInput
            width: 200
            font.pointSize: 20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            focus: true // Automatically focus on this field when the window is opened

            property string placeholderText: "E-mail:"

            Text {
                text: usernameInput.placeholderText
                color: "#aaa"
                visible: !usernameInput.text
            }
        }

        Text {
            id: textWarningLogin
            text: "Invalid password or login!"
            font.pointSize: 12
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: false
            font.bold: true
            color: "red"
        }

        // Password input field
        TextInput {
            id: passwordInput
            width: 200
            font.pointSize: 20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            echoMode: TextInput.Password // Hide the input characters

            property string placeholderText: "Password:"

            Text {
                text: passwordInput.placeholderText
                color: "#aaa"
                visible: !passwordInput.text
            }
        }

        Text {
            id: textWarningRegister
            text: "Invalid password!"
            font.pointSize: 12
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: false
            font.bold: true
            color: "red"
        }

        Image {
            id: image
            width: 200
            height: 400
            opacity: 0.25
            source: "img/boxer-dog.jpg"
            Layout.fillHeight: true
            Layout.fillWidth: true
            fillMode: Image.PreserveAspectFit
        }

        RowLayout {
            id: rowLayout
            //width: 800
            //height: 100
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

            Button {
                id: button
                width: 150
                text: qsTr("Log In")
                layer.textureMirroring: ShaderEffectSource.NoMirroring
                layer.format: ShaderEffectSource.RGBA
                font.pointSize: 20
                display: AbstractButton.TextOnly
                Layout.margins: 33
                onClicked: controller.onLogin(usernameInput.text, passwordInput.text)
                enabled: !controller.inProcess
            }

            Button {
                id: button1
                width: 150
                text: qsTr("Register")
                layer.textureMirroring: ShaderEffectSource.NoMirroring
                layer.format: ShaderEffectSource.RGBA
                font.pointSize: 20
                display: AbstractButton.TextOnly
                Layout.margins: 33
                enabled: !controller.inProcess
            }
        }
    }
    states: [
        State {
            name: "clicked"
        }
    ]

    Connections {
        target: controller
        onLoginResult: function(value) {
            textWarningLogin.visible = false
            textWarningRegister.visible = false

            if(value === 0) {
                var page2 = Qt.createComponent("Screen02.ui.qml");
                 if (page2.status === Component.Ready) {
                     page2.createObject(changer);
                }
            }
            else if(value === 1 || value === 2) {
                textWarningLogin.visible = true
            }
        }
    }
}
