
// This file is designed to hold all the tgui assets we need to possibly send to people.

/datum/asset/group/tgui
	subassets = list(/datum/asset/basic/tgui, /datum/asset/basic/fa)


/// Base tgui assets
/datum/asset/basic/tgui
	assets = list(
		"tgui/packages/tgui/public/tgui.bundle.js",
		"tgui/packages/tgui/public/tgui.bundle.css"
	)

/// FontAwesome assets
/datum/asset/basic/fa
	assets = list(
		"html/font-awesome/webfonts/fa-regular-400.eot",
		"html/font-awesome/webfonts/fa-regular-400.woff",
		"html/font-awesome/webfonts/fa-solid-900.eot",
		"html/font-awesome/webfonts/fa-solid-900.woff",
		"html/font-awesome/css/all.min.css",
		"html/font-awesome/css/v4-shims.min.css"
	)
