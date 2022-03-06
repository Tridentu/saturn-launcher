/*
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {

    property bool cfg_tilesLocked: plasmoid.configuration.tilesLocked

    Kirigami.FormLayout {

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: tilesLocked
            text: i18n("Lock all tiles: ")
            checked: cfg_tilesLocked
            onCheckedChanged: cfg_tilesLocked = checked
        }


        
    }

    Item {
        Layout.fillHeight: true
    }
}
