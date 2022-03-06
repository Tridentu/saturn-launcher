
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import QtQml 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3


BasePage {
    id: root
    sideBarComponent: KickoffListView {
        id: sideBar
        model: workspaceModel
        focus: true // needed for Loaders
        delegate: KickoffItemDelegate {
            url: ""
            description: ""
            width: view.availableWidth
            isCategory: true
        }
    }
    
    contentAreaComponent: EmptyPage {
        id: contentArea
        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                contentWidth, // exclude padding to avoid scrollbars automatically affecting implicitWidth
                                implicitHeaderWidth2,
                                implicitFooterWidth2)
        clip: root.height < root.contentHeight
        contentItem: SaturnTileView {
            id: tileGrid
            tileModel: plasmoid.rootItem.tileModel.value
            Timer {
                id: saveTimer
            
                interval: 2000
                onTriggered: tileModel.save()
            }
            onTileModelChanged: saveTimer.restart()
        }
    }
    
    ListModel {
        id: workspaceModel
        ListElement { display: "Workspace 1"; decoration: "workspace" }
        ListElement { display: "Workspace 2"; decoration: "workspace" }
        ListElement { display: "Workspace 3"; decoration: "workspace" }
        ListElement { display: "Workspace 4"; decoration: "workspace" }

        Component.onCompleted: {
            // Can't use a function in a QML ListElement declaration
            workspaceModel.setProperty(0, "display", i18nc("workspace in Home sidebar", "Workspace 1"))
            workspaceModel.setProperty(1, "display", i18nc("workspace in Home sidebar", "Workspace 2"))
            workspaceModel.setProperty(2, "display", i18nc("workspace in Home sidebar", "Workspace 3"))
            workspaceModel.setProperty(3, "display", i18nc("workspace in Home sidebar", "Workspace 4"))

        }
    }
    Binding {
        target: plasmoid.rootItem
        property: "sideBar"
        value: root.sideBarItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        target: plasmoid.rootItem
        property: "contentArea"
        value: root.contentAreaItem // NOT root.contentAreaItem.currentItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
   
}
