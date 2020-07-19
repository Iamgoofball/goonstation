
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
		"browserassets/css/fonts/tgui/fa-regular-400.eot",
		"browserassets/css/fonts/tgui/fa-regular-400.woff",
		"browserassets/css/fonts/tgui/fa-solid-900.eot",
		"browserassets/css/fonts/tgui/fa-solid-900.woff",
		"browserassets/css/tgui/font-awesome.min.css",
		"browserassets/css/tgui/v4-shims.min.css"
	)
