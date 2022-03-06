import QtQuick 2.15
import QtQuick.Controls 2.15


ScrollView {
	id: sectionedAppsView
    property alias listView: sectionedAppsListView
    property bool sectionsActive: false
	
	// The horizontal ScrollBar always appears in QQC2 for some reason.
	// The PC3 is drawn as if it thinks the scrollWidth is 0, which is
	// possible since it inits at width=350px, then changes to 0px until
	// the popup is opened before it returns to 350px.
	ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

	KickoffListView {
		id: sectionedAppsListView

		section.property: 'sectionKey'
		// section.criteria: ViewSection.FirstCharacter

		model: allAppsModel // Should be populated by the time this is created

		section.delegate: KickerSectionHeader {
			enableJumpToSection: true
		}

		delegate: KickoffItemDelegate {
            url: ""
            decoration: ""
			description:  "" 
		}
	}

	function scrollToTop() {
		sectionedAppsListView.view.positionViewAtBeginning()
	}

	function jumpToSection(section) {
		for (var i = 0; i < sectionedAppsListView.model.count; i++) {
			var app = sectionedAppsListView.model.get(i)
			if (section == app.sectionKey) {
				sectionedAppsListView.currentIndex = i
				sectionedAppsListView.view.positionViewAtIndex(i, ListView.Beginning)
				break
			}
		}
	}
}
