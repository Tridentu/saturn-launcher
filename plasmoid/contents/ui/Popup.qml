import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

MouseArea {
	id: popup
	property alias appsView: searchView.appsView

	RowLayout {
		anchors.fill: parent
		spacing: 0

		Item {
			id: sidebarPlaceholder
			
			implicitWidth: plasmoid.rootItem.sidebarWidth + plasmoid.rootItem.sidebarRightMargin
			Layout.fillHeight: true
		}

		SearchView {
			id: searchView
			Layout.fillHeight: true
		}

		
		
	}

	KickoffListView {
		id: sidebarView
	}

	MouseArea {
		visible: !plasmoid.configuration.tilesLocked && !(plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.RightEdge)
		anchors.top: parent.top
		anchors.right: parent.right
		width: PlasmaCore.Units.largeSpacing
		height: PlasmaCore.Units.largeSpacing
		cursorShape: Qt.WhatsThisCursor

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			icon: "help-hint"
			mainText: i18n("Resize?")
			subText: i18n("Meta + Right Click to resize the menu.")
		}
	}

	MouseArea {
		visible: !plasmoid.configuration.tilesLocked && !(plasmoid.location == PlasmaCore.Types.BottomEdge || plasmoid.location == PlasmaCore.Types.RightEdge)
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		width: PlasmaCore.Units.largeSpacing
		height: PlasmaCore.Units.largeSpacing
		cursorShape: Qt.WhatsThisCursor

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			icon: "help-hint"
			mainText: i18n("Resize?")
			subText: i18n("Meta + Right Click to resize the menu.")
		}
	}

	onClicked: searchView.searchField.forceActiveFocus()
}

