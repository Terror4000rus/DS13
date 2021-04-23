/*
	A tool modification is a little attachment for a tool that improves it in some way
	Tool modifications are generally permanant

	Some modifications have multiple bonuses. Some have drawbacks in addition to boosts
*/

/*/client/verb/debugmodifications()
	for (var/t in subtypesof(/obj/item/weapon/tool_modification))
		new t(usr.loc)
*/

/obj/item/weapon/tool_modification
	name = "tool modification"
	icon = 'icons/obj/tool_modifications.dmi'
	force = WEAPON_FORCE_HARMLESS
	w_class = ITEM_SIZE_SMALL
	//price_tag = 200

	var/adjective = "upgraded" //Added to the tool's name
	var/adjective_type = ADJECTIVE_TYPE_OPINION	//Defines in _defines/text.dm, determines the order that adjectives appear

	//The modification can be applied to a tool that has any of these qualities
	var/list/required_qualities = list()

	//If true, can only be applied to tools that use fuel
	var/req_fuel = FALSE

	//If true, can only be applied to tools that use a power cell
	var/req_cell = FALSE

	var/obj/item/weapon/tool/holder = null //The tool we're installed into
	matter = list(MATERIAL_STEEL = 1)

	//Actual effects of modifications
	var/precision = 0
	var/workspeed = 0
	var/degradation_mult = 1
	var/force_mult = 1	//Multiplies weapon damage
	var/force_mod = 0	//Adds a flat value to weapon damage
	var/powercost_mult = 1
	var/fuelcost_mult = 1
	var/bulk_mod = 0
	var/removeable = TRUE //Can this mod be uninstalled when removed. Set false to make it permanant
	var/recoverable = TRUE //If removed, do you get this mod back? Set false to make it delete when removed

/obj/item/weapon/tool_modification/examine(var/mob/user)
	.=..()
	if (precision > 0)
		user << SPAN_NOTICE("Enhances precision by [precision].")
	else if (precision < 0)
		user << SPAN_WARNING("Reduces precision by [abs(precision)].")
	if (workspeed)
		user << SPAN_NOTICE("Enhances workspeed by [workspeed*100]%.")

	if (degradation_mult < 1)
		user << SPAN_NOTICE("Reduces tool degradation by [(1-degradation_mult)*100]%.")
	else if	(degradation_mult > 1)
		user << SPAN_WARNING("Increases tool degradation by [(degradation_mult-1)*100]%.")

	if (force_mult != 1)
		user << SPAN_NOTICE("Increases tool damage by [(force_mult-1)*100]%.")
	if (force_mod)
		user << SPAN_NOTICE("Increases tool damage by [force_mod].")
	if (powercost_mult != 1)
		user << SPAN_WARNING("Modifies power usage by [(powercost_mult-1)*100]%.")
	if (fuelcost_mult != 1)
		user << SPAN_WARNING("Modifies fuel usage by [(fuelcost_mult-1)*100]%.")
	if (bulk_mod)
		user << SPAN_WARNING("Increases tool size by [bulk_mod].")

	if (!removeable)
		user << SPAN_DANGER("This modification is permanent, it can never be removed once applied!")
	else if (!recoverable)
		user << SPAN_WARNING("This modification cannot be recovered or re-used. It will be destroyed if you remove it from a tool.")

	if (required_qualities.len)
		user << SPAN_WARNING("Requires a tool with one of the following qualities:")
		user << english_list(required_qualities, and_text = " or ")




/******************************
	CORE CODE
******************************/


/obj/item/weapon/tool_modification/afterattack(obj/O, mob/user, proximity)

	if(!proximity) return
	try_apply(O, user)

/obj/item/weapon/tool_modification/proc/try_apply(var/obj/item/weapon/tool/O, var/mob/user)
	if (!can_apply(O, user))
		return FALSE

	return apply(O, user)


/obj/item/weapon/tool_modification/proc/can_apply(var/obj/item/weapon/tool/T, var/mob/user)
	if (isrobot(T))
		var/mob/living/silicon/robot/R = T
		if(!R.opened)
			user << SPAN_WARNING("You need to open [R]'s panel to access its tools.")
		var/list/robotools = list()
		for(var/obj/item/weapon/tool/robotool in R.module.modules)
			robotools.Add(robotool)
		if(robotools.len)
			var/obj/item/weapon/tool/chosen_tool = input(user,"Which tool are you trying to modify?","Tool Modification","Cancel") in robotools + "Cancel"
			if(chosen_tool == "Cancel")
				return
			try_apply(chosen_tool,user)
		else
			user << SPAN_WARNING("[R] has no modifiable tools.")
		return

	if (!istool(T))
		user << SPAN_WARNING("This can only be applied to a tool!")
		return

	if (T.modifications.len >= T.max_modifications)
		user << SPAN_WARNING("This tool can't fit anymore modifications!")
		return

	if (required_qualities.len)
		var/qmatch = FALSE
		for (var/q in required_qualities)
			if (T.ever_has_quality(q))
				qmatch = TRUE
				break

		if (!qmatch)
			user << SPAN_WARNING("This tool lacks the required qualities!")
			return

	if (req_fuel && !T.use_fuel_cost)
		user << SPAN_WARNING("This tool doesn't use fuel!")
		return

	if (req_cell && !T.use_power_cost)
		user << SPAN_WARNING("This tool doesn't use power!")
		return

	//No using multiples of the same modification
	for (var/obj/item/weapon/tool_modification/U in T.modifications)
		if (U.type == type)
			user << SPAN_WARNING("A modification of this type is already installed!")
			return

	return TRUE


//Applying an modification to a tool is a mildly difficult process
/obj/item/weapon/tool_modification/proc/apply(var/obj/item/weapon/tool/T, var/mob/user)

	if (user)
		user.visible_message(SPAN_NOTICE("[user] starts applying the [src] to [T]"), SPAN_NOTICE("You start applying the [src] to [T]"))
		if (!use_tool(user = user, target =  T, base_time = WORKTIME_NORMAL, required_quality = null, fail_chance = FAILCHANCE_EASY+T.unreliability, required_stat = "construction", forced_sound = WORKSOUND_WRENCHING))
			return FALSE
		user << SPAN_NOTICE("You have successfully installed [src] in [T]")
		user.drop_from_inventory(src)
	//If we get here, we succeeded in the applying
	holder = T
	forceMove(T)
	T.modifications.Add(src)
	T.refresh_modifications()
	return TRUE

//This does the actual numerical changes.
//The tool itself asks us to call this, and it resets itself before doing so
/obj/item/weapon/tool_modification/proc/apply_values()
	if (!holder)
		return

	holder.precision += precision
	holder.workspeed += workspeed
	holder.degradation *= degradation_mult
	holder.force *= force_mult
	holder.switched_on_force *= force_mult
	holder.force += force_mod
	holder.switched_on_force += force_mod
	holder.use_fuel_cost *= fuelcost_mult
	holder.use_power_cost *= powercost_mult
	holder.extra_bulk += bulk_mod
	holder.adjectives[adjective] = adjective_type
	return TRUE