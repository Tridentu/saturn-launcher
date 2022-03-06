import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T

EmptyPage {
 
    id: searchView
    property bool showSearch: false
	property bool isEditingTile: false
	
    property alias jumpToLetterView: jumpToLetterView
    property alias appsView: appsView
		
    readonly property int appAreaWidth: {
		if (isEditingTile) {
			return Math.max(350, 350 * PlasmaCore.Units.devicePixelRatio)
		} else if (showSearch) {
			return plasmoid.configuration.appAreaWidth
		} else {
			return 0
		}
	}
	
	Item {
        id: stackViewContainer
        anchors.fill: parent
        KickoffListView {
                id: appsView
                objectName: "appsView"
                mainContentView: true
                implicitWidth: normalPage.implicitWidth
                implicitHeight: normalPage.implicitHeight
                // Forces the function be re-run every time runnerModel.count changes.
                // This is absolutely necessary to make the search view work reliably.
                model: plasmoid.rootItem.runnerModel.count ? plasmoid.rootItem.runnerModel.modelForRow(0) : null
                delegate: KickoffItemDelegate {
                    width: view.availableWidth
                    isSearchResult: true
                }
                activeFocusOnTab: true
                // always focus the first item in the header focus chain
                KeyNavigation.tab: header.nextItemInFocusChain()
                T.StackView.onActivated: {
                    plasmoid.rootItem.sideBar = null
                    plasmoid.rootItem.contentArea = appsView
                }
                function show(animation) {
                    if (stackView.currentItem != appsView) {
                        stackView.delegate = animation || stackView.panUp
                        stackView.push({
                            item: appsView,
                            replace: true,
                        })
                    }
                }
                
        }
        
        SectionedAppsView {
			id: sectionedAppsView
			visible: false
                    
			

			function show(animation) {
				if (stackView.currentItem != sectionedAppsView && sectionedAppsView.sectionsActive) {
					stackView.delegate = animation || stackView.panUp
					stackView.push({
						item: sectionedAppsView,
						replace: true,
					})
				}
				sectionedAppsView.scrollToTop()
			}
		}
        
        JumpToLettersView {
			id: jumpToLetterView
			visible: false

			function showLetters() {
				plasmoid.rootItem.order = "alphabetical"
				show()
			}

			function showCategories() {
				plasmoid.rootItem.order = "categories"
				show()
			}

			function show() {
				if (stackView.currentItem != jumpToLetterView) {
					stackView.delegate = stackView.zoomOut
					stackView.push({
						item: jumpToLetterView,
						replace: true,
					})
				}
			}
		}
        
        
        
		
		
        SearchStackView {
         id: stackView
         anchors.fill: parent
         initialItem: appsView
        }
    }
	
	
	Shortcut {
       sequence: "Ctrl+J"
       onActivated: {
           if (plasmoid.rootItem.order == "alphabetical") {
               jumpToLetterView.showCategories()
           } else {
                jumpToLetterView.showLetters()
           }
       }
    }
	
    implicitWidth: appAreaWidth
}

