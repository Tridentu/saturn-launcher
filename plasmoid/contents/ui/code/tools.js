/*
    SPDX-FileCopyrightText: 2013 Aurélien Gâteau <agateau@kde.org>
    SPDX-FileCopyrightText: 2013-2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2017 Ivan Cukic <ivan.cukic@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

.pragma library

function fillActionMenu(i18n, actionMenu, actionList, favoriteModel, favoriteId) {
    // Accessing actionList can be a costly operation, so we don't
    // access it until we need the menu.

    var actions = createFavoriteActions(i18n, favoriteModel, favoriteId);

    if (actions) {
        if (actionList && actionList.length > 0) {
            var separator = { "type": "separator" };
            actionList.push(separator);
            // actionList = actions.concat(actionList); // this crashes Qt O.o
            actionList.push.apply(actionList, actions);
        } else {
            actionList = actions;
        }
    }

    actionMenu.actionList = actionList;
}

function createFavoriteActions(i18n, favoriteModel, favoriteId) {
    if (!favoriteModel || !favoriteId || !favoriteModel.enabled) {
        return null;
    }


    if (favoriteModel.activities === undefined ||
        favoriteModel.activities.runningActivities.length <= 1) {
        var action = {};

        if (favoriteModel.isFavorite(favoriteId)) {
            action.text = i18n("Remove from Favorites");
            action.icon = "bookmark-remove";
            action.actionId = "_kicker_favorite_remove";
        } else if (favoriteModel.maxFavorites == -1 || favoriteModel.count < favoriteModel.maxFavorites) {
            action.text = i18n("Add to Favorites");
            action.icon = "bookmark-new";
            action.actionId = "_kicker_favorite_add";
        } else {
            return null;
        }

        action.actionArgument = { favoriteModel: favoriteModel, favoriteId: favoriteId };

        return [action];

    } else {
        var actions = [];

        var linkedActivities = favoriteModel.linkedActivitiesFor(favoriteId);

        var activities = favoriteModel.activities.runningActivities;

        // Adding the item to link/unlink to all activities

        var linkedToAllActivities =
            !(linkedActivities.indexOf(":global") === -1);

        actions.push({
            text      : i18n("On All Activities"),
            checkable : true,

            actionId  : linkedToAllActivities ?
                            "_kicker_favorite_remove_from_activity" :
                            "_kicker_favorite_set_to_activity",
            checked   : linkedToAllActivities,

            actionArgument : {
                favoriteModel: favoriteModel,
                favoriteId: favoriteId,
                favoriteActivity: ""
            }
        });


        // Adding items for each activity separately

        var addActivityItem = function(activityId, activityName) {
            var linkedToThisActivity =
                !(linkedActivities.indexOf(activityId) === -1);

            actions.push({
                text      : activityName,
                checkable : true,
                checked   : linkedToThisActivity && !linkedToAllActivities,

                actionId :
                    // If we are on all activities, and the user clicks just one
                    // specific activity, unlink from everything else
                    linkedToAllActivities ? "_kicker_favorite_set_to_activity" :

                    // If we are linked to the current activity, just unlink from
                    // that single one
                    linkedToThisActivity ? "_kicker_favorite_remove_from_activity" :

                    // Otherwise, link to this activity, but do not unlink from
                    // other ones
                    "_kicker_favorite_add_to_activity",

                actionArgument : {
                    favoriteModel    : favoriteModel,
                    favoriteId       : favoriteId,
                    favoriteActivity : activityId
                }
            });
        };

        // Adding the item to link/unlink to the current activity

        addActivityItem(favoriteModel.activities.currentActivity, i18n("On the Current Activity"));

        actions.push({
            type: "separator",
            actionId: "_kicker_favorite_separator"
        });

        // Adding the items for each activity

        activities.forEach(function(activityId) {
            addActivityItem(activityId, favoriteModel.activityNameForId(activityId));
        });

        return [{
            text       : i18n("Show in Favorites"),
            icon       : "favorite",
            subActions : actions
        }];
    }

    
}


function triggerAction(model, index, actionId, actionArgument) {
    function startsWith(txt, needle) {
        return txt.substr(0, needle.length) === needle;
    }

    if (startsWith(actionId, "_kicker_favorite_")) {
        handleFavoriteAction(actionId, actionArgument);
        return;
    }

    var closeRequested = model.trigger(index, actionId, actionArgument);

    if (closeRequested) {
        return true;
    }

    return false;
}

function handleFavoriteAction(actionId, actionArgument) {
    var favoriteId = actionArgument.favoriteId;
    var favoriteModel = actionArgument.favoriteModel;

    console.log(actionId);

    if (favoriteModel === null || favoriteId == null) {
        return null;
    }

    if (actionId == "_kicker_favorite_remove") {
        console.log("Removing from all activities");
        favoriteModel.removeFavorite(favoriteId);
    } else if (actionId == "_kicker_favorite_add") {
        console.log("Adding to global activity");
        favoriteModel.addFavorite(favoriteId);
    } else if (actionId == "_kicker_favorite_remove_from_activity") {
        console.log("Removing from a specific activity");
        favoriteModel.removeFavoriteFrom(favoriteId, actionArgument.favoriteActivity);

    } else if (actionId == "_kicker_favorite_add_to_activity") {
        console.log("Adding to another activity");
        favoriteModel.addFavoriteTo(favoriteId, actionArgument.favoriteActivity);

    } else if (actionId == "_kicker_favorite_set_to_activity") {
        console.log("Removing the item from the favourites, and re-adding it just to be on a specific activity");
        favoriteModel.setFavoriteOn(favoriteId, actionArgument.favoriteActivity);

    }
}

function parseDropUrl(url) {
	var startsWithAppsScheme = url.indexOf('applications:') === 0 // Search Results add this prefix
	if (startsWithAppsScheme) {
		// console.log('parseDropUrl', 'startsWithAppsScheme', url)
		url = url.substr('applications:'.length)
	}

	var workingDir = Qt.resolvedUrl('.')
	var endsWithDesktop = url.indexOf('.desktop') === url.length - '.desktop'.length
	var isRelativeDesktopUrl = endsWithDesktop && (
		url.indexOf(workingDir) === 0
		// || url.indexOf('file:///usr/share/applications/') === 0
		// || url.indexOf('/.local/share/applications/') >= 0
		|| url.indexOf('/share/applications/') >= 0 // 99% certain this desktop file should be accessed relatively.
	)
	// console.log('parseDropUrl', workingDir, endsWithDesktop, isRelativeDesktopUrl)
	// console.log('onUrlDropped', 'url', url)
	if (isRelativeDesktopUrl) {
		// Remove the path because .favoriteId is just the file name.
		// However passing the favoriteId in mimeData.url will prefix the current QML path because it's a QUrl.
		var tokens = url.toString().split('/')
		var favoriteId = tokens[tokens.length-1]
		// console.log('isRelativeDesktopUrl', tokens, favoriteId)
		return favoriteId
	} else {
		return url
	}
}
