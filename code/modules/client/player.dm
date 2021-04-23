/*
	Player datums are created and stored on a one-per-ckey basis. They persist for the entire session, across any number of reconnects and mobs.
	Use them to store data which needs to persist in such a manner.
*/

/datum/player
	var/key
	var/client
	var/mob
	var/is_necromorph = FALSE

	//If true, this player is registered as a patron, and gets access to certain perks
	//most of these perks can also be accessed by admins, without patron status
	var/patron = FALSE

	//Last cached coordinates, set on logout
	var/list/last_location = list("x" = 0, "y" = 0, "z" = 0)

/datum/player/New(var/newkey)
	src.key = newkey
	update_patron()

	.=..()

/datum/player/proc/update_patron()
	if ((key in GLOB.patron_keys))
		patron = TRUE
	else
		patron = FALSE

	var/client/C = get_client()
	if (C && C.prefs && C.prefs.loadout)
		C.prefs.loadout.set_prefs(C.prefs)

/datum/player/proc/Login()
	GLOB.logged_in_event.raise_event(src)
	return

/datum/player/proc/get_mob()
	return locate(mob)

/datum/player/get_client()
	return locate(client)

/datum/player/proc/cache_location(var/atom/location)
	last_location = list("x" = location.x, "y" = location.y, "z" = location.z)

/datum/player/proc/get_last_location()
	return locate(last_location["x"],last_location["y"],last_location["z"])

/mob/proc/register_client_and_player()
	if (!client || !ckey)
		return

	var/datum/player/me = get_or_create_player(ckey)
	if (!me)
		return null
	me.client = "\ref[src.client]"
	me.mob = "\ref[src]"


	//Existing stuff i might replace
	GLOB.player_list |= src
	GLOB.key_to_mob[key] = src



/mob/proc/player_login()
	register_client_and_player()

	var/datum/player/me = get_or_create_player(key)
	if (!me)
		return
	me.Login()



/*
	Getter procs
*/
/proc/get_or_create_player(var/key)
	if (!key)
		return null
	key = ckey(key)
	if (!GLOB.players[key])
		GLOB.players[key] = new /datum/player(key)
	return GLOB.players[key]


/mob/proc/get_player()
	if (!client || !client.ckey)	//TODO: Figure out how to make this work for disconnected players in future. I know the key field is not nulled
		return null

	return get_or_create_player(client.ckey)


/proc/get_player_from_key(var/key)
	if (!key)
		return null
	key = ckey(key)
	return GLOB.players[key]


/proc/get_preferences_from_key(var/key)
	var/datum/player/P = get_player_from_key(key)
	var/client/C = locate(P.client)
	if (istype(C))
		return C.prefs
	else
		return null




/*
	Necromorph helpers
*/

/datum/player/is_necromorph()
	return is_necromorph

/mob/proc/set_necromorph(var/state)
	var/datum/player/P = get_or_create_player(ckey)
	if (P)
		P.is_necromorph = state
		if (P.is_necromorph())
			SSnecromorph.necromorph_players[ckey] = P
		else
			SSnecromorph.necromorph_players -= ckey