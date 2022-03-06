import QtQuick 2.15


QtObject {
    id: appObj
    
    property var tile: null
    
    
    readonly property bool isGroup: tile && tile.tileType == "group"

    

    
    readonly property color defaultBackgroundColor: isGroup ? "#ECEFF4" : "#BF616A"
    readonly property var appIcon: app ? app.decoration : null

    readonly property string appLabel: app ? app.display : ""
    readonly property string favoriteId: tile && tile.url || ''
	readonly property var app: favoriteId ? tileGridModel.getApp(favoriteId) : null
	
	readonly property string labelText: tile && tile.label || appLabel || appUrl || ""

	readonly property bool defaultShowIcon: isGroup ? false : true
	readonly property string appUrl: app ? app.url : ""

    readonly property var iconSource: tile && tile.icon || appIcon
	readonly property bool iconFill: tile && typeof tile.iconFill !== "undefined" ? tile.iconFill : false
	readonly property bool showIcon: tile && typeof tile.showIcon !== "undefined" ? tile.showIcon : defaultShowIcon
	readonly property bool showLabel: tile && typeof tile.showLabel !== "undefined" ? tile.showLabel : true
    
    readonly property color backgroundColor: tile && typeof tile.backgroundColor !== "undefined" ? tile.backgroundColor : defaultBackgroundColor
	readonly property string backgroundImage: tile && typeof tile.backgroundImage !== "undefined" ? tile.backgroundImage : ""
	readonly property bool backgroundGradient: tile && typeof tile.gradient !== "undefined" ? tile.gradient : plasmoid.configuration.defaultTileGradient
    
    readonly property int tileX: tile && typeof tile.x !== "undefined" ? tile.x : 0
	readonly property int tileY: tile && typeof tile.y !== "undefined" ? tile.y : 0
	readonly property int tileW: tile && typeof tile.w !== "undefined" ? tile.w : defaultTileW
	readonly property int tileH: tile && typeof tile.h !== "undefined" ? tile.h : defaultTileH
	
	readonly property var groupRect: {
		if (isGroup) {
			return tileGrid.getGroupAreaRect(tile)
		} else {
			return null
		}
	}
	
	function hasActionList() {
		return app ? tileGridModel.indexHasActionList(app.indexInModel) : false
	}

	function getActionList() {
		return app ? tileGridModel.getActionListAtIndex(app.indexInModel) : []
	}

	function addActionList(menu) {
		if (hasActionList()) {
			var actionList = getActionList()
			menu.addActionList(actionList, tileGridModel, appObj.app.indexInModel)
		}
	}
}
