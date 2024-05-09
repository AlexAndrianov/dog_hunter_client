// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import DogHunter 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Controls 6.2
import QtQuick.Layouts

Window {
    width: 400
    height: 800

    visible: true
    title: "dog_hunter"

    Controller {
        id: controller
    }

    StackView {
        id: changer
        anchors.fill: parent
        initialItem: Screen01{}
    }
}

