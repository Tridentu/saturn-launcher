
import QtQuick 2.15
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.MenuItem {
	id: presetMenuItem
	icon: "list-add-symbolic"
	text: i18n("Add Tile Preset")

	//---
	function addDefault() {
		var pos = tileGrid.findOpenPos(6, 6)
		// addCommunication(pos.x, pos.y)
		addExplore(pos.x, pos.y)
	}

	function isAppInstalled(appId) {
		return allAppsModel.hasApp(appId)
	}

	function addTilePreset(x, y, tileData) {
		var appId = tileData.url
		if (isAppInstalled(appId)) {
			return tileGrid.addTile(x, y, tileData)
		} else {
			return null
		}
	}
	
	function addTilePresetFromDesktop(x, y, tileData){
        tileData.url = "/usr/share/applications/" +  tileData.url
        return addTilePreset(x, y, tileData)
    }

	function addGroupPreset(x, y, groupData, tileFnList) {
		var group = tileGrid.addGroup(x, y, groupData)
		var tileX = group.x
		var tileY = y + group.h
		for (var i = 0; i < tileFnList.length; i++) {
			var tileFn = tileFnList[i]
			var tile = tileFn(tileX, tileY)
			if (tile) {
				// TODO: Support Wrap
				tileX += tile.w
			}
		}
	}

	function addProductivity(x, y) {
		addGroupPreset(x, y, {
			label: i18n("Work"),
		}, [
			addWriter,
			addCalc,
		])
	}
	
	function addCommunication(x, y) {
		addGroupPreset(x, y, {
			label: i18n("Talk"),
		}, [
			addJaqubSuite,
		])
	}

	function addJaqubSuite(x, y) {
        return addTilePreset(x, y, {
			url: 'jaqubsuite.desktop',
            icon: "internet-chat",
			backgroundColor: '#5E81AC69',
		})
    }
	
	function addExplore(x, y) {
		addGroupPreset(x, y, {
			label: i18n("Explore"),
		}, [
			addAppCenter,
			addWebBrowser,
		])
	}


	//---
	function addWriter(x, y) {
		return addTilePreset(x, y, {
			url: 'libreoffice-writer.desktop',
			backgroundColor: '#5E81ACB7',
		})
	}
	function addCalc(x, y) {
		return addTilePreset(x, y, {
			url: 'libreoffice-calc.desktop',
			backgroundColor: '#5E81AC69',
		})
	}
	
	function addMail(x, y) {
		var tile = addKMail(x, y)
		if (!tile) {
			tile = addGmail(x, y)
		}
		return tile
	}
	function addKMail(x, y) {
		return addTilePreset(x, y, {
			url: 'org.kde.kmail2.desktop',
		})
	}
	function addGmail(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'https://mail.google.com/mail/u/0/#inbox',
			label: i18n("Gmail"),
			icon: 'mail-message',
			backgroundColor: '#B48EAD25',
		})
	}

	function addAppCenter(x, y) {

		if (isAppInstalled('acacia.desktop')) {
			return addTilePreset(x, y, {
				url: 'acacia.desktop',
                icon: "aptana",
				label: i18n("Acacia PM Software Center"),
			})
		} else if (isAppInstalled('org.kde.discover.desktop')) {
			return addTilePreset(x, y, {
				url: 'org.kde.discover.desktop',
				label: i18n("Discover Software Center"),
			})
		} else {
			return null
		}
	}

	function addWebBrowser(x, y) {
		if (isAppInstalled('firefox.desktop')) {
			return addTilePreset(x, y, {
				url: 'firefox.desktop',
                icon: "firefox",
				label: i18n("Firefox Web Browser"),
			})
        }
	}

	function addSteam(x, y) {
		return addTilePreset(x, y, {
			url: 'steam.desktop',
		})
	}
	
	//---
	PlasmaComponents.ContextMenu {
		visualParent: presetMenuItem.action

		PlasmaComponents.MenuItem {
			icon: "checklist"
			text: i18n("Productivity")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addProductivity(pos.x, pos.y)
			}
		}

		PlasmaComponents.MenuItem {
			icon: "internet-web-browser"
			text: i18n("Explore")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addExplore(pos.x, pos.y)
			}
		}

		PlasmaComponents.MenuItem {
			icon: "mail-message"
			text: i18n("Gmail")
			onClicked: {
				var tile = presetMenuItem.addGmail(cellContextMenu.cellX, cellContextMenu.cellY)
				tileGrid.editTile(tile)
			}
		}
	}
}
