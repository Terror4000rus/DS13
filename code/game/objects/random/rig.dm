/obj/random/hardsuit
	name = "Random Rig"
	desc = "This is a random rig control module."
	icon = 'icons/obj/rig_modules.dmi'
	icon_state = "generic"

/obj/random/hardsuit/item_to_spawn()
	return pickweight(list(/obj/item/weapon/rig/security,
				/obj/item/weapon/rig/engineering,
				/obj/item/weapon/rig/mining,
				/obj/item/weapon/rig/vintage = 0.5,
				/obj/item/weapon/rig/advanced = 0.5,
				/obj/item/weapon/rig/patrol = 0.5,
				/obj/item/weapon/rig/industrial,
				/obj/item/weapon/rig/eva,
				/obj/item/weapon/rig/civilian))


/obj/random/rig_module
	name = "Random Rig module"
	desc = "This is a random rig control module."
	icon = 'icons/obj/rig_modules.dmi'
	icon_state = "generic"

/obj/random/rig_module
	possible_spawns = list(/obj/item/rig_module/kinesis = 2,
	/obj/item/rig_module/kinesis/advanced = 0.5,
	/obj/item/rig_module/healthbar/advanced = 1,
	/obj/item/rig_module/storage = 0.75,
	/obj/item/rig_module/storage/heavy = 0.5,
	/obj/item/rig_module/vision = 0.2,
	/obj/item/rig_module/vision/multi = 0.1,
	/obj/item/rig_module/vision/nvg = 0.5,
	/obj/item/rig_module/vision/thermal = 0.2,
	/obj/item/rig_module/chem_dispenser/ninja = 0.2,
	/obj/item/rig_module/voice = 0.5,
	/obj/item/rig_module/maneuvering_jets = 1,
	/obj/item/rig_module/self_destruct = 0.2,
	/obj/item/rig_module/power_sink = 0.5,
	/obj/item/rig_module/grenade_launcher = 0.2,
	/obj/item/rig_module/grenade_launcher/cleaner = 0.5,
	/obj/item/rig_module/grenade_launcher/smoke = 0.5,
	/obj/item/rig_module/grenade_launcher/mfoam = 0.5,
	/obj/item/rig_module/grenade_launcher/light = 0.5,
	/obj/item/rig_module/hotswap = 0.5,
	/obj/item/rig_module/power_sink = 1,
	/obj/item/rig_module/extension/speedboost = 1,
	/obj/item/rig_module/extension/speedboost/advanced = 0.5
	)

/*
	Only contains the good stuff
*/
/obj/random/rig_module/rare
	possible_spawns = list(/obj/item/rig_module/kinesis/advanced = 0.5,
	/obj/item/rig_module/healthbar/advanced = 1,
	/obj/item/rig_module/storage/heavy = 0.5,
	/obj/item/rig_module/vision/thermal = 0.2,
	/obj/item/rig_module/chem_dispenser/ninja = 0.2,
	/obj/item/rig_module/self_destruct = 0.2,
	/obj/item/rig_module/power_sink = 0.5,
	/obj/item/rig_module/grenade_launcher = 0.2,
	/obj/item/rig_module/grenade_launcher/smoke = 0.5,
	/obj/item/rig_module/grenade_launcher/mfoam = 0.5,
	/obj/item/rig_module/extension/speedboost = 1,
	/obj/item/rig_module/extension/speedboost/advanced = 0.5
	)