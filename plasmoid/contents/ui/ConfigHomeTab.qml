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
    property real cfg_tileScale: plasmoid.configuration.tileScale
    property real cfg_tileMargin: plasmoid.configuration.tileMargin
    property int cfg_tileLabelAlignment: plasmoid.configuration.tileLabelAlignment

    Kirigami.FormLayout {

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: tilesLocked
            Kirigami.FormData.label: i18n("Lock all tiles: ")
            checked: cfg_tilesLocked
            onCheckedChanged: cfg_tilesLocked = checked
        }

        SpinBox {
            id: tileScale
            Kirigami.FormData.label: i18n("Tile scale: ")
            from: 10
            to: 200
            stepSize: 5
            property real realValue: value / 100
            validator: DoubleValidator {
                bottom: Math.min(tileScale.from, tileScale.to)
                top:  Math.max(tileScale.from, tileScale.to)
            }
            
            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale, 'f', 0) + "%"
            }
            
            Component.onCompleted: {
                tileScale.value = cfg_tileScale * 100
            }
            
            onValueChanged: cfg_tileScale = realValue
        }
        
          SpinBox {
            id: tileMargin
            Kirigami.FormData.label: i18n("Tile margin: ")
            from: 1
            to: 20
            stepSize: 1
            validator: DoubleValidator {
                bottom: Math.min(tileScale.from, tileScale.to)
                top:  Math.max(tileScale.from, tileScale.to)
            }
            
            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale, 'f', 0) + "px"
            }
            
            Component.onCompleted: {
                tileMargin.value = cfg_tileMargin
            }
            
            onValueChanged: cfg_tileMargin = value
        }
        
        RadioButton {
            id: leftLabel
            Kirigami.FormData.label: i18n("Align tile labels to:")
            text: i18nc("Part of a sentence: 'Show tile labels to the left'", "The left")
            ButtonGroup.group: labelAlignmentGroup
            property int index: 0
            checked: plasmoid.configuration.tileLabelAlignment == index
        }

        RadioButton {
            id: middleLabel
            text: i18nc("Part of a sentence: 'Show tile labels in the middle'", "The middle")
            ButtonGroup.group: labelAlignmentGroup
            property int index: 1
            checked: plasmoid.configuration.tileLabelAlignment == index
        }

      RadioButton {
            id: rightLabel
            text: i18nc("Part of a sentence: 'Show tile labels to the right'", "The right")
            ButtonGroup.group: labelAlignmentGroup
            property int index: 2
            checked: plasmoid.configuration.tileLabelAlignment == index
        }

        
    }
    
    ButtonGroup {
        id: labelAlignmentGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_tileLabelAlignment = checkedButton.index
            }
        }
    }
    Item {
        Layout.fillHeight: true
    }
}
