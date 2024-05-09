/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts
import QtLocation 6.7
import QtPositioning

Rectangle {
    id: thirdUseCase
    width: 400
    height: 800
    anchors.fill: parent

    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    ColumnLayout {
        anchors.fill: parent

        Plugin {
            id: mapPlugin
            name: "osm" // OpenStreetMap plugin
        }

        Map {
            id: map
            //anchors.fill: parent
            Layout.fillHeight: true
            Layout.fillWidth: true
            plugin: mapPlugin
            center: QtPositioning.coordinate(-37.8136, 144.9631) // Set center coordinates to Melbourne // Set initial center coordinates (London)
            zoomLevel: 14 // Set initial zoom level

            WheelHandler {
                id: wheel
                // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
                // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
                // and we don't yet distinguish mice and trackpads on Wayland either
                acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                 ? PointerDevice.Mouse | PointerDevice.TouchPad
                                 : PointerDevice.Mouse
                rotationScale: 1/120
                property: "zoomLevel"
            }
            DragHandler {
                id: drag
                target: null
                onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
            }
            Shortcut {
                enabled: map.zoomLevel < map.maximumZoomLevel
                sequence: StandardKey.ZoomIn
                onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
            }
            Shortcut {
                enabled: map.zoomLevel > map.minimumZoomLevel
                sequence: StandardKey.ZoomOut
                onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
            }

            MapItemView {
                model: ListModel {
                    id: pointModel
                }

                delegate: MapQuickItem {
                    coordinate: position
                    anchorPoint.x: image.width / 2
                    anchorPoint.y: image.height

                    sourceItem: Image {
                        id: image
                        source: "img/map_point.png"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("On map Selected")

                    var coordinate = map.toCoordinate(Qt.point(mouseX, mouseY))

                    var resSel = controller.tryToSelectWalk(coordinate.latitude, coordinate.longitude)

                    if(resSel === true)
                        return

                    pointModel.clear()
                    pointModel.append({ "position": coordinate })
                    circleMap.center = coordinate
                }
            }

            MapCircle {
                id: circleMap
                color: "green"
                radius: 1000
                center: map.center
                opacity: 0.1
            }
        }

        RowLayout {
            Layout.margins: 2
            Layout.fillWidth: true

            Button {
                id: radiusSetButton
                width: 150
                height: 80
                text: qsTr("Set Radius: ")
                font.pointSize: 14
                display: AbstractButton.TextOnly
                Layout.margins: 1
                onClicked: {
                    circleMap.radius = parseInt(radiusInput.text)
                }
            }

            TextInput {
                id: radiusInput
                width: 200
                font.pointSize: 14
                Layout.margins: 1
                text: circleMap.radius.toString()
            }
        }

        Button {
            id: searchButton
            Layout.fillWidth: true
            text: qsTr("Search Dogs Walks")
            font.pointSize: 14
            display: AbstractButton.TextOnly
            Layout.margins: 1
            onClicked: {
                var walkInfos = controller.getWalkInfo(circleMap.radius, circleMap.center.latitude, circleMap.center.longitude)

                console.log(walkInfos.length.toString())
                pointModel.clear()

                for (var i = 0; i < walkInfos.length; ++i) {
                    pointModel.append({ "position": QtPositioning.coordinate(walkInfos[i].latitude, walkInfos[i].longitude) })
                }
            }
        }

        RowLayout {
            Layout.margins: 2
            Layout.fillWidth: true

            Text {
                text: "Selected Dog Owner Name:"
                font.pointSize: 12
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }

            Text {
                id: sdoName
                text: controller.selDogOwnerName
                font.pointSize: 14
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }
        }

        RowLayout {
            Layout.margins: 2
            Layout.fillWidth: true

            Text {
                text: "Dog On Walk Name:"
                font.pointSize: 12
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }

            Text {
                id: dowName
                text: controller.selDogOnWalkName
                font.pointSize: 14
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }
        }

        RowLayout {
            Layout.margins: 2
            Layout.fillWidth: true

            Text {
                text: "Dog On Walk Age:"
                font.pointSize: 12
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }

            Text {
                id: dowAge
                text: controller.selDogOnWalkAge
                font.pointSize: 14
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }
        }

        RowLayout {
            Layout.margins: 2
            Layout.fillWidth: true

            Text {
                text: "Dog On Walk Breede:"
                font.pointSize: 12
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }

            Text {
                id: dowBreede
                text: controller.selDogOnWalkBreede
                font.pointSize: 14
                font.bold: true
                color: "black"
                enabled: controller.walkWasSelected
            }
        }

        Button {
            id: attendButton
            Layout.fillWidth: true
            text: qsTr("Attend this walk")
            font.pointSize: 10
            display: AbstractButton.TextOnly
            Layout.margins: 1
            visible: controller.walkWasSelected
            onClicked: {
                var page4 = Qt.createComponent("Screen04.ui.qml");
                 if (page4.status === Component.Ready) {
                     page4.createObject(changer);
                }
            }
        }
    }

    states: [
        State {
            name: "clicked"
        }
    ]
}
