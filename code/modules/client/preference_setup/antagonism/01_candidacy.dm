#define CLOSE_TABLE	if (open_table) {. += "</table><br>";\
open_table = FALSE;}
/datum/preferences
	var/list/never_be_special_role
	var/list/be_special_role
	var/auto_necroqueue = TRUE
	var/ghost_candidacy = TRUE

/datum/category_item/player_setup_item/antagonism/candidacy
	name = "Candidacy"
	sort_order = 1

/datum/category_item/player_setup_item/antagonism/candidacy/load_character(var/savefile/S)
	from_file(S["be_special"],           pref.be_special_role)
	from_file(S["never_be_special"],     pref.never_be_special_role)
	from_file(S["auto_necroqueue"],           pref.auto_necroqueue)
	from_file(S["ghost_candidacy"], 			 pref.ghost_candidacy)
	//Safeguard to make sure it defaults to on
	if (isnull(pref.ghost_candidacy))
		pref.ghost_candidacy = TRUE

/datum/category_item/player_setup_item/antagonism/candidacy/save_character(var/savefile/S)
	to_file(S["be_special"],             pref.be_special_role)
	to_file(S["never_be_special"],       pref.never_be_special_role)
	to_file(S["auto_necroqueue"],           pref.auto_necroqueue)
	to_file(S["ghost_candidacy"], 			 pref.ghost_candidacy)

/datum/category_item/player_setup_item/antagonism/candidacy/sanitize_character()
	if(!istype(pref.be_special_role))
		pref.be_special_role = list()
	if(!istype(pref.never_be_special_role))
		pref.never_be_special_role = list()

	var/special_roles = valid_special_roles()
	var/old_be_special_role = pref.be_special_role.Copy()
	var/old_never_be_special_role = pref.never_be_special_role.Copy()
	for(var/role in old_be_special_role)
		if(!(role in special_roles))
			pref.be_special_role -= role
	for(var/role in old_never_be_special_role)
		if(!(role in special_roles))
			pref.never_be_special_role -= role

/datum/category_item/player_setup_item/antagonism/candidacy/content(var/mob/user)
	. = list()
	var/open_table = FALSE
	. += "Auto Join Necroqueue:"
	. += {"<a class='linkActive noIcon checkbox' unselectable='on' title='If ticked, you will automatically be placed in the necroqueue when joining the necromorph team, or leaving a necromorph body.'  style='display:inline-block;' onclick='document.location="?src=\ref[src];auto_necroqueue=[pref.auto_necroqueue ? "false" : "true"]"' ><div><form><input type='checkbox' [pref.auto_necroqueue ? "checked" : ""]></form></div></a><br>"}

	. += "<b>Special Role Availability:</b><br>"
	. += "<b>Necromorphs:</b><br>"
	. += "<table>"
	open_table = TRUE
	for(var/ntype in subtypesof(/datum/species/necromorph))
		var/datum/species/necromorph/N = ntype
		if (!initial(N.preference_settable))
			continue
		var/necro_id = initial(N.name)
		. += "<tr><td>[necro_id]: </td><td>"
		if(necro_id in pref.never_be_special_role)
			. += "<a href='?src=\ref[src];del_special=[necro_id]'>Yes</a> <span class='linkOn'>No</span></br>"
		else
			. += "<span class='linkOn'>Yes</span> <a href='?src=\ref[src];add_never=[necro_id]'>No</a></br>"
		. += "</td></tr>"
	. += "<br>"
	CLOSE_TABLE
	var/list/all_antag_types = GLOB.all_antag_types_
	var/antag_category

	for(var/antag_type in all_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		//We have entered a new category

		if (!antag.preference_candidacy_toggle)
			continue
		if (antag.preference_candidacy_category != antag_category)
			antag_category = antag.preference_candidacy_category
			CLOSE_TABLE
			.+= "<b>[antag_category]:</b><br>"
			.+= "<table>"

			open_table = TRUE


		. += "<tr><td>[antag.role_text]: </td><td>"
		if(jobban_isbanned(preference_mob(), antag.id) || (antag.id == MODE_MALFUNCTION && jobban_isbanned(preference_mob(), "AI")))
			. += "<span class='danger'>\[BANNED\]</span><br>"
		else if(antag.id in pref.be_special_role)
			. += "<span class='linkOn'>High</span> <a href='?src=\ref[src];del_special=[antag.id]'>Low</a> <a href='?src=\ref[src];add_never=[antag.id]'>Never</a></br>"
		else if(antag.id in pref.never_be_special_role)
			. += "<a href='?src=\ref[src];add_special=[antag.id]'>High</a> <a href='?src=\ref[src];del_special=[antag.id]'>Low</a> <span class='linkOn'>Never</span></br>"
		else
			. += "<a href='?src=\ref[src];add_special=[antag.id]'>High</a> <span class='linkOn'>Low</span> <a href='?src=\ref[src];add_never=[antag.id]'>Never</a></br>"
		. += "</td></tr>"
	CLOSE_TABLE

	. += "<table>"
	open_table = TRUE

	var/list/ghost_traps = get_ghost_traps()
	for(var/ghost_trap_key in ghost_traps)
		var/datum/ghosttrap/ghost_trap = ghost_traps[ghost_trap_key]
		if(!ghost_trap.list_as_special_role)
			continue

		. += "<tr><td>[(ghost_trap.ghost_trap_role)]: </td><td>"
		if(banned_from_ghost_role(preference_mob(), ghost_trap))
			. += "<span class='danger'>\[BANNED\]</span><br>"
		else if(ghost_trap.pref_check in pref.be_special_role)
			. += "<span class='linkOn'>High</span> <a href='?src=\ref[src];del_special=[ghost_trap.pref_check]'>Low</a> <a href='?src=\ref[src];add_never=[ghost_trap.pref_check]'>Never</a></br>"
		else if(ghost_trap.pref_check in pref.never_be_special_role)
			. += "<a href='?src=\ref[src];add_special=[ghost_trap.pref_check]'>High</a> <a href='?src=\ref[src];del_special=[ghost_trap.pref_check]'>Low</a> <span class='linkOn'>Never</span></br>"
		else
			. += "<a href='?src=\ref[src];add_special=[ghost_trap.pref_check]'>High</a> <span class='linkOn'>Low</span> <a href='?src=\ref[src];add_never=[ghost_trap.pref_check]'>Never</a></br>"
		. += "</td></tr>"
	. += "</table>"

	//. += "Auto Join ERT: "
	//. += {"<a class='linkActive noIcon checkbox' unselectable='on' title='If ticked, you will automatically join ert.'  style='display:inline-block;' onclick='document.location="?src=\ref[src];auto_ert=[pref.auto_ert ? "false" : "true"]"' ><div><form><input type='checkbox' [pref.auto_ert ? "checked" : ""]></form></div></a><br>"}

	/*
	. += "<b>ERT Availability:</b><br>"
	. += "<table>"
	for(var/ert_type in subtypesof(/datum/emergency_call))
		var/datum/emergency_call/ert = ert_type
		var/ert_id = initial(ert.pref_name)
		. += "<tr><td>[ert_id]: </td><td>"
		if(ert_id in pref.never_be_special_role)
			. += "<a href='?src=\ref[src];del_special=[ert_id]'>Yes</a> <span class='linkOn'>No</span></br>"
		else
			. += "<span class='linkOn'>Yes</span> <a href='?src=\ref[src];add_never=[ert_id]'>No</a></br>"
		. += "</td></tr>"
	. += "</table>"
	*/
	. = jointext(.,null)

/datum/category_item/player_setup_item/proc/banned_from_ghost_role(var/mob, var/datum/ghosttrap/ghost_trap)
	for(var/ban_type in ghost_trap.ban_checks)
		if(jobban_isbanned(mob, ban_type))
			return 1
	return 0

/datum/category_item/player_setup_item/antagonism/candidacy/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["add_special"])
		if(!(href_list["add_special"] in valid_special_roles()))
			return TOPIC_HANDLED
		pref.be_special_role |= href_list["add_special"]
		pref.never_be_special_role -= href_list["add_special"]
		return TOPIC_REFRESH

	if(href_list["del_special"])
		if(!(href_list["del_special"] in valid_special_roles()))
			return TOPIC_HANDLED
		pref.be_special_role -= href_list["del_special"]
		pref.never_be_special_role -= href_list["del_special"]
		return TOPIC_REFRESH

	if(href_list["add_never"])
		pref.be_special_role -= href_list["add_never"]
		pref.never_be_special_role |= href_list["add_never"]
		return TOPIC_REFRESH

	if(href_list["auto_necroqueue"])
		if(href_list["auto_necroqueue"] == "false")
			pref.auto_necroqueue = FALSE
		if(href_list["auto_necroqueue"] == "true")
			pref.auto_necroqueue = TRUE
		return TOPIC_REFRESH


	return ..()

/datum/category_item/player_setup_item/antagonism/candidacy/proc/valid_special_roles()
	var/list/private_valid_special_roles = list()

	for(var/ntype in subtypesof(/datum/species/necromorph))
		var/datum/species/necromorph/N = ntype
		private_valid_special_roles += initial(N.name)

	for(var/antag_type in GLOB.all_antag_types_)
		private_valid_special_roles += antag_type

	var/list/ghost_traps = get_ghost_traps()
	for(var/ghost_trap_key in ghost_traps)
		var/datum/ghosttrap/ghost_trap = ghost_traps[ghost_trap_key]
		if(!ghost_trap.list_as_special_role)
			continue
		private_valid_special_roles += ghost_trap.pref_check

	for(var/ert_type in subtypesof(/datum/emergency_call))
		var/datum/emergency_call/ert = ert_type
		private_valid_special_roles += initial(ert.pref_name)

	return private_valid_special_roles

/client/proc/wishes_to_be_role(var/role)
	if(!prefs)
		return FALSE
	if(role in prefs.be_special_role)
		return 2
	if(role in prefs.never_be_special_role)
		return FALSE
	return 1	//Default to "sometimes" if they don't opt-out.
