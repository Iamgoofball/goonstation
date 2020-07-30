//http request stuff stolen from /tg/ to go along with the rust-g http request stuff, modified by goof for 15.ai stuff
/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url
	var/options
	var/raw_data = FALSE

	var/_raw_response

/datum/http_request/proc/prepare(method, url, body = "", list/headers, options)
	if (!length(headers))
		headers = ""
	else
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers
	src.options = options

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers, options)

/datum/http_request/proc/begin_async()
	if (in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, options)

	if (isnull(text2num(id)))
		stack_trace("Proc error: [id]")
		_raw_response = "Proc error: [id]"
	else
		in_progress = TRUE

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/r = rustg_http_check_request(id)

	if (r == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = r
		in_progress = FALSE
		return TRUE

/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error

#define UNTIL(X) while(!(X)) sleep(world.tick_lag)

var/list/friendly_voice_names = list(
	"Artifical Intelligence" = "GLaDOS (Portal)",
	"Fry Cook" = "SpongeBob",
	"Librarian" = "Twilight Sparkle",
	"Shy" = "Fluttershy",
	"Fixer" = "Miss Pauling",
	"Superstar" = "Rise Kujikawa",
	"Skeleton" = "Sans",
	"Plant Based Lifeform" = "Flowey",
	"Goat" = "Toriel")

var/list/available_emotions = list(
	"GLaDOS (Portal)" = list("μ = 0.31"),
	"SpongeBob" = list("μ = 0.30"),
	"Twilight Sparkle" = list("μ = 0.59", "μ = 0.33"),
	"Fluttershy" = list("μ = 0.33"),
	"Miss Pauling" = list("μ = 0.30"),
	"Rise Kujikawa" = list("μ = 0.56", "μ = 0.29"),
	"Sans" = list("Neutral"),
	"Flowey" = list("Neutral"),
	"Toriel" = list("Neutral")
	)



/mob/living/silicon/ai/verb/announcement()
	set category = "AI Commands"
	set name = "15.ai VOX Announcement"
	if(announcing_vox > world.time)
		boutput(src, "<span class='notice'>The VOX system is still recharging. Please wait about 30 seconds past your last usage of it.</span>")
		return
	var/character_to_use = input(src, "Choose what 15.ai character to use:", "15.ai Character Choice")  as null|anything in friendly_voice_names
	if(!character_to_use)
		return
	var/emotion_to_use = input(src, "Choose what emotion to use! Higher numbers are more emotive:", "Emotion Choice")  as null|anything in available_emotions[friendly_voice_names[character_to_use]]
	if(!emotion_to_use)
		return
	var/max_characters = 300 // magic number but its the cap 15 allows
	var/message = input(src, "Use the power of 15.ai to say anything! (300 character OR 3 sentence maximum)", "15.ai VOX System", src.last_announcement) as text|null

	if(!message || announcing_vox > world.time)
		return

	if(length(message) > max_characters)
		boutput(src, "<span class='notice'>You have too many characters! You used [length(message)] characters, you need to lower this to [max_characters] or lower.</span>")
		return
	var/regex/check_for_bad_chars = regex("\[^a-zA-Z!?.,' :\]+")
	if(check_for_bad_chars.Find(message))
		boutput(src, "<span class='notice'>These characters are not available on the 15.ai system: [english_list(check_for_bad_chars.group)].</span>")
		return

	last_announcement = message

	announcing_vox = world.time + 30 SECONDS

	message_admins("[key_name(src)] started making a 15.AI announcement with the following message: [message]")
	play_vox_word(message, friendly_voice_names[character_to_use], emotion_to_use, src, src.z, null)


/proc/play_vox_word(message, character, emotion, mob/living/silicon/ai/speaker, z_level, mob/only_listener)
	var/api_url = "https://api.fifteen.ai/app/getAudioFile"
	var/static/vox_voice_number = 0
	var/datum/http_request/req = new()
	vox_voice_number++
	req.prepare(RUSTG_HTTP_METHOD_POST, api_url, "{\"character\":\"[character]\",\"text\":\"[message]\",\"emotion\":\"[emotion]\"}", list("Content-Type" = "application/json", "User-Agent" = "Goonstation server"), json_encode(list("output_filename" = "data/vox_[vox_voice_number].wav")))
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()
	if(res.status_code == 200)
		message_admins("[key_name(speaker)] finished making a 15.AI announcement with the following message: [message]")
		speaker.say(";[message]")
		for(var/C in clients)
			if(C)
				C << sound("data/vox_[vox_voice_number].wav", environment = -1)
		fdel("data/vox_[vox_voice_number].wav")
		return 1
	else
		if(!res.status_code)
			message_admins("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error: [req._raw_response]")
		else
			message_admins("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error code: [res.status_code]")
		boutput(speaker, "The speech synthesizer failed to return audio. Your speech cooldown has been reset. Please try again.")
		fdel("data/vox_[vox_voice_number].wav")
		speaker.announcing_vox = world.time
	return 0