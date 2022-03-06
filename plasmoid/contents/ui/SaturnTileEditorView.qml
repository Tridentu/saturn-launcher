import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0 as QtDialogs

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

ColumnLayout {

    id: tileEditorView
    Layout.alignment: Qt.AlignVCenter
    
    
    SaturnAppObject {
        id: appObj 
    }
    
    function close() {
		parent.active = false
	}
    
    property alias tile: appObj.tile

    function resetView(){
        tile = null
    }
    
    function resetTile() {
		delete appObj.tile.showIcon
		delete appObj.tile.showLabel
		delete appObj.tile.label
		delete appObj.tile.icon
		delete appObj.tile.backgroundColor
		delete appObj.tile.backgroundImage
		appObj.tileChanged()
		tileGrid.tileModelChanged()
	}

	RowLayout {
        PlasmaExtras.Heading {
            Layout.fillWidth: true
            level: 2
            text: i18n("Edit Tile")
        }
        
        PlasmaComponents3.Button {
			text: i18n("Reset Tile")
			onClicked: resetTile()
		}
		
		PlasmaComponents3.Button {
			text: i18n("Close")
			onClicked: {
				tileEditorView.close()
			}
		}
    }
    
    PlasmaExtras.ScrollArea {
        id: scrollView
        height: parent.height * 1.5
		width: parent.width
		ColumnLayout {
            id: scrollContent
			Layout.fillWidth: true
            Layout.fillHeight: true

			width: scrollView.availableWidth
            SaturnTileEditorField {
				// visible: appObj.isLauncher
				title: i18n("Url")
				key: 'url'
			}
			
			SaturnTileEditorField {
				id: labelField
				title: i18n("Label")
				placeholderText: appObj.appLabel
				key: 'label'
				checkedKey: 'showLabel'
			}
			
			SaturnTileEditorField {
				id: iconField
				title: i18n("Icon")
				// placeholderText: appObj.appIcon ? appObj.appIcon.toString() : ''
				key: 'icon'
				checkedKey: 'showIcon'
				checkedDefault: true

				PlasmaComponents3.Button {
					icon.name: "document-open"
					onClicked: iconDialog.open()

					KQuickAddons.IconDialog {
						id: iconDialog
						onIconNameChanged: iconField.text = iconName
					}
				}
			}
			
			SaturnTileEditorField {
				id: backgroundImageField
				title: i18n("Background Image")
				key: 'backgroundImage'

				PlasmaComponents3.Button {
					icon.name: 'document-open'
					onClicked: imagePicker.open()

					QtDialogs.FileDialog {
						id: imagePicker

						title: i18n("Choose an image")

						selectFolder: false
						selectMultiple: false

						nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

						onFileUrlChanged: {
							backgroundImageField.text = fileUrl
							if (fileUrl) {
								labelField.checked = false
								iconField.checked = false
							}
						}
					}
				}
			}
			
			
			SaturnTileEditorPresetTiles {
				title: i18n("Preset Tiles")
			}
			
			SaturnTileEditorColorGroup {
				title: i18n("Background Color")
				placeholderText: "#0000000"
				key: 'backgroundColor'
			}
			
			SaturnTileEditorRectField {
				title: i18n("Position / Size")
			}

			Item { // Consume the extra space below
				Layout.fillHeight: true
			}
        }
    }
    
    function show() {
        
	}

    Connections {
		target: plasmoid.rootItem.tileModel

		onLoaded: {
			// Base64JsonString.save() will create a new JavaScript array [],
			// and our current tile {} reference will be incorrect, which breaks the tile editor.
			// We could keep a reference to the tile's index in the array, and make sure
			// the tile's url did not change, but there's no guarantee we won't overwrite data
			// during an Import, so just close the view.
			tileEditorView.close()
		}
	}
    
    function open(tile) {
		resetView()
		tileEditorView.tile = tile
		show()
	}
}
