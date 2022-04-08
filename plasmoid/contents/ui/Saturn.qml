/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtQuick.Window 2.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PC3
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
    id: saturn

    // The properties are defined here instead of the singleton because each
    // instance of Saturn requires different instances of these properties

    property bool inPanel: plasmoid.location === PlasmaCore.Types.TopEdge
        || plasmoid.location === PlasmaCore.Types.RightEdge
        || plasmoid.location === PlasmaCore.Types.BottomEdge
        || plasmoid.location === PlasmaCore.Types.LeftEdge
    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Used to prevent the width from changing frequently when the scrollbar appears or disappears
    property bool mayHaveGridWithScrollBar: plasmoid.configuration.applicationsDisplay === 0
        || (plasmoid.configuration.favoritesDisplay === 0 && plasmoid.rootItem.rootModel.favoritesModel.count > 16)
    property string order: "categories"
	onOrderChanged: allAppsModel.refresh()
    readonly property string recentAppsSectionKey: 'RECENT_APPS'
    
    readonly property real tileScale: plasmoid.configuration.tileScale

    readonly property int cellMarginUnits: plasmoid.configuration.tileMargin
    readonly property real cellMargin: cellMarginUnits * tileScale * PlasmaCore.Units.devicePixelRatio
    readonly property real cellPushedMargin: cellMargin * 2
    readonly property int sidebarRightMargin: 4 * PlasmaCore.Units.devicePixelRatio
    readonly property int sidebarButtonSize: 24 * PlasmaCore.Units.devicePixelRatio
    readonly property int cellSizeUnits: 80 - cellMarginUnits*2
	readonly property int cellSize: cellSizeUnits * tileScale * PlasmaCore.Units.devicePixelRatio

    //BEGIN Models
    property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false
        appNameFormat: 0
        appletInterface: plasmoid

        flat: true // have categories, but no subcategories
        sorted: plasmoid.configuration.alphaSort
        showSeparators: false
        showTopLevelItems: false

        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: true
        showRecentDocs: false
        showRecentContacts: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        recentOrdering: plasmoid.configuration.recentOrdering

        
        property var tileGridModel: KickerAppModel {
            id: tileGridModel
            Component.onCompleted: {
                
            }

        }
        
        Component.onCompleted: {
            favoritesModel.initForClient("org.plasma.kde.kicker.favorites.instance-" + plasmoid.id)

            if (!plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(plasmoid.configuration.favorites);
                }
                plasmoid.configuration.favoritesPortedToKAstats = true;
            }
            if (!autoPopulate) {
                    debouncedRefresh.restart()
                    // console.log('rootModel.refresh.star', Date.now())
                    // rootModel.refresh()
                    // console.log('rootModel.refresh.done', Date.now())
            }
            rootModel.refresh();
        }
        
        
    }

    property Kicker.RunnerModel runnerModel: Kicker.RunnerModel {
        query: saturn.searchField ? saturn.searchField.text : ""
        appletInterface: plasmoid
        mergeResults: true
        favoritesModel: rootModel.favoritesModel
    }

    property Kicker.ComputerModel computerModel: Kicker.ComputerModel {
        appletInterface: plasmoid
        favoritesModel: rootModel.favoritesModel
        systemApplications: plasmoid.configuration.systemApplications
        Component.onCompleted: {
            //systemApplications = plasmoid.configuration.systemApplications;
        }
    }

    property Kicker.RecentUsageModel recentUsageModel: Kicker.RecentUsageModel {
        favoritesModel: rootModel.favoritesModel
    }

    property Kicker.RecentUsageModel frequentUsageModel: Kicker.RecentUsageModel {
        favoritesModel: rootModel.favoritesModel
        ordering: 1 // Popular / Frequently Used
    }
    
    
    KickerListModel{
		id: allAppsModel
		onItemTriggered: {
			// console.log('allAppsModel.onItemTriggered')
			plasmoid.expanded = false
		}

		function getRecentApps() {
			var recentAppList = [];

			//--- populate
			var model = rootModel.modelForRow(0)
			if (model) {
				parseModel(recentAppList, model)
			} else {
				console.log('getRecentApps() recent apps model is null')
			}

			//--- filter
			recentAppList = recentAppList.filter(function(item){
				//--- filter kcmshell5 applications since they show up blank (undefined)
				if (typeof item.name === 'undefined') {
					return false;
				} else {
					return true;
				}
			});

			//--- first 5 items
			recentAppList = recentAppList.slice(0, plasmoid.configuration.numRecentApps)

			//--- section
			for (var i = 0; i < recentAppList.length; i++) {
				var item = recentAppList[i];
				item.sectionKey = recentAppsSectionKey
			}

			return recentAppList;
		}

		function refreshRecentApps() {
			// console.log('refreshRecentApps')
			if (debouncedRefresh.running) {
				// We're about to do a full refresh so don't bother doing a partial update.
				return
			}
			var recentAppList = getRecentApps();
			var recentAppCount = 5
			if (recentAppCount == recentAppList.length) {
				// Do a partial update since we're only updating properties.
				refreshing()

				// Overwrite the exisiting items.
				for (var i = 0; i < recentAppList.length; i++) {
					var item = recentAppList[i]
					list[i] = item
					set(i, item)
				}

				refreshed()
			} else {
				// We'll be removing items, so just replace the entire list.
				refresh()
			}
		}

		property int categoryStartIndex: 2 // Skip Recent Apps, All Apps
		property int categoryEndIndex: rootModel.count - 1 // Skip Power

		function getCategory(rootIndex) {
			var modelIndex = rootModel.index(rootIndex, 0)
			var categoryLabel = rootModel.data(modelIndex, Qt.DisplayRole)
			var categoryIcon = rootModel.data(modelIndex, Qt.DecorationRole)
			// console.log('categoryLabel', categoryLabel, categoryIcon)
			var categoryModel = rootModel.modelForRow(rootIndex)
			var appList = []
			if (categoryModel) {
				parseModel(appList, categoryModel)
			} else {
				console.log('allAppsModel.getCategory', rootIndex, categoryModel, 'is null')
			}
			
			for (var i = 0; i < appList.length; i++) {
				var item = appList[i];
				item.sectionKey = categoryLabel
				item.sectionIcon = categoryIcon
			}
			return appList
		}
		function getAllCategories() {
			var appList = [];
			for (var i = categoryStartIndex; i < categoryEndIndex; i++) { // Skip Recent Apps, All Apps, ... and Power
			// for (var i = 0; i < rootModel.count; i++) {
				appList = appList.concat(getCategory(i))
			}
			return appList
		}

		function getAllApps() {
			//--- populate list
			var appList = [];
			var model = rootModel.modelForRow(1)
			if (model) {
				parseModel(appList, model)
			} else {
				console.log('getAllApps() all apps model is null')
			}

			//--- filter
			// var powerActionsList = [];
			// var sceneUrls = [];
			// appList = appList.filter(function(item){
			// 	//--- filter multiples
			// 	if (item.url) {
			// 		if (sceneUrls.indexOf(item.url) >= 0) {
			// 			return false;
			// 		} else {
			// 			sceneUrls.push(item.url);
			// 			return true;
			// 		}
			// 	} else {
			// 		return true;
			// 		//--- filter
			// 		// if (item.parentModel.toString().indexOf('SystemModel') >= 0) {
			// 		// 	// console.log(item.description, 'removed');
			// 		// 	powerActionsList.push(item);
			// 		// 	return false;
			// 		// } else {
			// 		// 	return true;
			// 		// }
			// 	}
			// });
			// powerActionsModel.list = powerActionsList; 

			//---
			for (var i = 0; i < appList.length; i++) {
				var item = appList[i];
				if (item.name) {
					var firstCharCode = item.name.charCodeAt(0);
					if (48 <= firstCharCode && firstCharCode <= 57) { // isDigit
						item.sectionKey = '0-9';
					} else if ((33 <= firstCharCode && firstCharCode <= 47)
						|| (58 <= firstCharCode && firstCharCode <= 64)
						|| (91 <= firstCharCode && firstCharCode <= 96)
						|| (123 <= firstCharCode && firstCharCode <= 126)
					) { // isSymbol
						item.sectionKey = '&';
					} else {
						item.sectionKey = item.name.charAt(0).toUpperCase();
					}
				} else {
					item.sectionKey = '?';
				}
				// console.log(item.sectionKey, item.name)
			}

			//--- sort
			appList = appList.sort(function(a,b) {
				if (a.name && b.name) {
					return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
				} else {
					// console.log(a, b);
					return 0;
				}
			})


			return appList
		}

		function refresh() {
			refreshing()
			
			//--- Apps
			var appList = []
			if (order == "categories") {
				appList = getAllCategories()
			} else {
				appList = getAllApps()
			}

			//--- Recent Apps
			if (plasmoid.configuration.showRecentApps) {
				var recentAppList = getRecentApps();
				appList = recentAppList.concat(appList); // prepend
			}

			//--- Power
			// var systemModel = rootModel.modelForRow(rootModel.count - 1)
			// var systemList = []
			// parseModel(systemList, systemModel)
			// powerActionsModel.list = systemList;

			//--- parse sectionIcons
			allAppsModel.sectionIcons = {}
			for (var i = 0; i < appList.length; i++) {
				var item = appList[i]
				if (item.sectionKey && item.sectionIcon) {
					allAppsModel.sectionIcons[item.sectionKey] = item.sectionIcon
				}
			}

			//--- apply model
			allAppsModel.list = appList;
			// allAppsModel.log();

			//--- listen for changes
			// for (var i = 0; i < runnerModel.count; i++){
			// 	var runner = runnerModel.modelForRow(i);
			// 	if (!runner.listenersBound) {
			// 		runner.countChanged.connect(debouncedRefresh.logAndRestart)
			// 		runner.dataChanged.connect(debouncedRefresh.logAndRestart)
			// 		runner.listenersBound = true;
			// 	}
			// }

			refreshed()
		}
		
		
	}
    
    
    function runApp(url) {
        var rowModel = plasmoid.rootItem.rootModel.modelForRow(1)
                                    for(var i = 0; i < rowModel.count; i++){
                                        var modelIndex = rowModel.index(i, 0)
                                        var favoriteId = rowModel.data(modelIndex, Qt.UserRole + 3)
                                        if (favoriteId == url){
                                            rowModel.trigger(i, "", null)
                                            return
                                        }
                                    }
                                    console.log("No app")
    }

    
    //END

    //BEGIN UI elements
    // Set in FullRepresentation.qml
    property Item header: null

    // Set in Header.qml
    property PC3.TextField searchField: null

    // Set in FullRepresentation.qml, ApplicationPage.qml, PlacesPage.qml
    property Item sideBar: null // is null when searching
    property Item contentArea: null // is searchView when searching

    // Set in NormalPage.qml
    property Item footer: null
    //END

    //BEGIN Metrics
    readonly property PlasmaCore.FrameSvgItem backgroundMetrics: PlasmaCore.FrameSvgItem {
        // Inset defaults to a negative value when not set by margin hints
        readonly property real leftPadding: margins.left - Math.max(inset.left, 0)
        readonly property real rightPadding: margins.right - Math.max(inset.right, 0)
        readonly property real topPadding: margins.top - Math.max(inset.top, 0)
        readonly property real bottomPadding: margins.bottom - Math.max(inset.bottom, 0)
        readonly property real spacing: leftPadding
        visible: false
        imagePath: plasmoid.formFactor === PlasmaCore.Types.Planar ? "widgets/background" : "dialogs/background"
    }
    //END
    
    

    Plasmoid.switchWidth: plasmoid.fullRepresentationItem ? plasmoid.fullRepresentationItem.Layout.minimumWidth : -1
    Plasmoid.switchHeight: plasmoid.fullRepresentationItem ? plasmoid.fullRepresentationItem.Layout.minimumHeight : -1

    Plasmoid.preferredRepresentation: plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: FullRepresentation { focus: true }

    Plasmoid.icon: plasmoid.configuration.icon

    Plasmoid.compactRepresentation: MouseArea {
        id: compactRoot

        implicitWidth: PlasmaCore.Units.iconSizeHints.panel
        implicitHeight: PlasmaCore.Units.iconSizeHints.panel

        Layout.minimumWidth: {
            if (!saturn.inPanel) {
                return PlasmaCore.Units.iconSizes.small
            }

            if (saturn.vertical) {
                return -1;
            } else {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.height) * buttonIcon.aspectRatio;
            }
        }

        Layout.minimumHeight: {
            if (!saturn.inPanel) {
                return PlasmaCore.Units.iconSizes.small
            }

            if (saturn.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return -1;
            }
        }

        Layout.maximumWidth: {
            if (!saturn.inPanel) {
                return -1;
            }

            if (saturn.vertical) {
                return PlasmaCore.Units.iconSizeHints.panel;
            } else {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.height) * buttonIcon.aspectRatio;
            }
        }

        Layout.maximumHeight: {
            if (!saturn.inPanel) {
                return -1;
            }

            if (saturn.vertical) {
                return Math.min(PlasmaCore.Units.iconSizeHints.panel, parent.width) * buttonIcon.aspectRatio;
            } else {
                return PlasmaCore.Units.iconSizeHints.panel;
            }
        }

        hoverEnabled: true
        // For some reason, onClicked can cause the plasmoid to expand after
        // releasing sometimes in plasmoidviewer.
        // plasmashell doesn't seem to have this issue.
        onClicked: plasmoid.expanded = !plasmoid.expanded

        DropArea {
            id: compactDragArea
            anchors.fill: parent
        }

        Timer {
            id: expandOnDragTimer
            // this is an interaction and not an animation, so we want it as a constant
            interval: 250
            running: compactDragArea.containsDrag
            onTriggered: plasmoid.expanded = true
        }

        PlasmaCore.IconItem {
            id: buttonIcon

            readonly property double aspectRatio: (saturn.vertical ? implicitHeight / implicitWidth
                : implicitWidth / implicitHeight)

            anchors.fill: parent
            source: plasmoid.icon
            active: parent.containsMouse || compactDragArea.containsDrag
            smooth: true
            roundToIconSize: aspectRatio === 1
        }
    }

    KCoreAddons.KUser {
			id: kuser
    }
		
   Item {
		//--- Detect Changes
		// Changes aren't bubbled up to the RootModel, so we need to detect changes somehow.
		
		// Recent Apps
		Repeater {
			model: rootModel.count >= 0 ? rootModel.modelForRow(0) : []
			
			Item {
				Component.onCompleted: {
					// console.log('debouncedRefreshRecentApps', index)
					if (plasmoid.configuration.showRecentApps) {
						debouncedRefreshRecentApps.restart()
					}
				}
			}
		}

		// All Apps
		Repeater { // A-Z
			model: rootModel.count >= 2 ? rootModel.modelForRow(1) : []

			Item {
				property var parentModel: rootModel.modelForRow(1).modelForRow(index)

				Repeater { // Aaa ... Azz (Apps)
					model: parentModel && parentModel.hasChildren ? parentModel : []

					Item {
						Component.onCompleted: {
							// console.log('depth2', index, display, model)
							debouncedRefresh.restart()
						}
					}
				}

				// Component.onCompleted: {
				// 	console.log('depth1', index, display, model)
				// }
			}
		}

		Timer {
			id: debouncedRefresh
			interval: 100
			onTriggered:{
                rootModel.refresh()
                allAppsModel.refresh()
            }
		}

		Timer {
			id: debouncedRefreshRecentApps
			interval: debouncedRefresh.interval
			onTriggered: allAppsModel.refreshRecentApps()
		}
		
		
	}


		
    Kicker.ProcessRunner {
        id: processRunner;
    }

    function action_menuedit() {
        processRunner.runMenuEditor();
    }
    
    Popup {
		id: popup
		anchors.fill: parent
	}
	
	property var tileModel: Base64JsonString {
		configKey: 'tileModel'
		defaultValue: []
    }
    
    property var workspaceModel: Base64JsonString {
		configKey: 'workspaceModel'
		defaultValue: [
          {
            active: false,
            tileModel: []
          },
          {
            active: false,
            tileModel: []

          },
          {
            active: false,
            tileModel: []

          },
          {
            active: false,
            tileModel: []

          },
          {
            active: false,
            tileModel: []

          },
          {
            active: false,
            tileModel: []

          },
          {
            active: false,
            tileModel: []

          }
        ]
    }
    
    
    property int currentWorkspace: 2
    
    readonly property int workspaceIndex: currentWorkspace - 2
    
    function activateWorkspace(index){
        
    }
    
    
    
    
    

    Component.onCompleted: {
        if (plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            plasmoid.activationTogglesExpanded = true
        }
        if (plasmoid.immutability !== PlasmaCore.Types.SystemImmutable) {
            plasmoid.setAction("menuedit", i18n("Edit Applications…"), "kmenuedit");
        }
        console.log(JSON.stringify(tileModel.value))
    }
    
    
} // root
