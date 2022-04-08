
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
            onViewSelected: {
                openWorkspace(index)
            }
        }
    }
    
    property var saturnTileGrid: undefined;
    
      function openWorkspace(index){
           saturnTileGrid.workspaceId = index
            if(index <= 0){
                saturnTileGrid.tileModel = plasmoid.rootItem.tileModel.value
            } else {
                if(plasmoid.rootItem.workspaceModel.value) {
                    var tileGroup = plasmoid.rootItem.workspaceModel.value[index - 1];
                    saturnTileGrid.tileModel = tileGroup.tileModel
                }
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
                onTriggered: {
                    if (tileGrid.workspaceId <= 0){
                        tileModel.save();
                    } else {
                        plasmoid.rootItem.workspaceModel.save()
                    }
                }
            }
            onTileModelChanged: saveTimer.restart()
            Component.onCompleted: {
                saturnTileGrid = tileGrid;
            }
        }
    }
    
    ListModel {
        id: workspaceModel
        
      
        
        ListElement { display: "Workspace 1"; decoration: "workspace"; }
        ListElement { display: "Workspace 2"; decoration: "workspace"; }
        ListElement { display: "Workspace 3"; decoration: "workspace";  }
        ListElement { display: "Workspace 4"; decoration: "workspace"; }
        ListElement { display: "Workspace 5"; decoration: "workspace"; }
        ListElement { display: "Workspace 6"; decoration: "workspace";  }
        ListElement { display: "Workspace 7"; decoration: "workspace";  }
        ListElement { display: "Workspace 8"; decoration: "workspace";  }

        Component.onCompleted: {
            // Can't use a function in a QML ListElement declaration
            workspaceModel.setProperty(0, "display", i18nc("workspace in Home sidebar", "Workspace 1"))
            workspaceModel.setProperty(1, "display", i18nc("workspace in Home sidebar", "Workspace 2"))
            workspaceModel.setProperty(2, "display", i18nc("workspace in Home sidebar", "Workspace 3"))
            workspaceModel.setProperty(3, "display", i18nc("workspace in Home sidebar", "Workspace 4"))
            workspaceModel.setProperty(4, "display", i18nc("workspace in Home sidebar", "Workspace 5"))
            workspaceModel.setProperty(5, "display", i18nc("workspace in Home sidebar", "Workspace 6"))
            workspaceModel.setProperty(6, "display", i18nc("workspace in Home sidebar", "Workspace 7"))
            workspaceModel.setProperty(7, "display", i18nc("workspace in Home sidebar", "Workspace 8"))

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
