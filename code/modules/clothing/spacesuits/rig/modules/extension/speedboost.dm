/obj/item/rig_module/extension/speedboost
	name = "Femoral Exoskeleton"
	desc = "An internal frame which supports leg motions, allowing the user to run approximately 15% faster than normal"
	extension_type = /datum/extension/rig_speedboost
	active_power_cost = 500


/obj/item/rig_module/extension/speedboost/advanced
	name = "Advanced Femoral Exoskeleton"
	desc = "An internal frame which supports leg motions, allowing the user to run approximately 25% faster than normal"
	extension_type = /datum/extension/rig_speedboost/advanced
	active_power_cost = 750



/datum/extension/rig_speedboost
	flags = EXTENSION_FLAG_IMMEDIATE
	statmods = list(STATMOD_MOVESPEED_ADDITIVE = 0.15)

/datum/extension/rig_speedboost/advanced
	statmods = list(STATMOD_MOVESPEED_ADDITIVE = 0.25)