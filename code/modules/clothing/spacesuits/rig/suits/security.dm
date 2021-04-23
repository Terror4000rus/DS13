/obj/item/weapon/rig/security
	name = "security rig"
	desc = "A lightweight and flexible armoured rig suit, designed for riot control and shipboard disciplinary enforcement."
	icon_state = "ds_security_rig"
	armor = list(melee = 57.5, bullet = 60, laser = 60, energy = 25, bomb = 60, bio = 100, rad = 60)
	online_slowdown = RIG_MEDIUM
	acid_resistance = 1.75	//Contains a fair bit of plastic

	chest_type = /obj/item/clothing/suit/space/rig/security
	helm_type =  /obj/item/clothing/head/helmet/space/rig/security
	boot_type =  /obj/item/clothing/shoes/magboots/rig/security
	glove_type = /obj/item/clothing/gloves/rig/security

	initial_modules = list(
		/obj/item/rig_module/healthbar,
		/obj/item/rig_module/storage,
		/obj/item/rig_module/grenade_launcher/light,	//These grenades are harmless illumination
		/obj/item/rig_module/device/paperdispenser,	//For warrants and paperwork
		/obj/item/rig_module/device/pen,
		/obj/item/rig_module/vision/nvgsec
		)

/obj/item/clothing/suit/space/rig/security
	name = "suit"
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA, ACCESSORY_SLOT_ARMOR_S, ACCESSORY_SLOT_ARMOR_M)
	restricted_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA, ACCESSORY_SLOT_ARMOR_S)

/obj/item/clothing/gloves/rig/security
	name = "gloves"

/obj/item/clothing/shoes/magboots/rig/security
	name = "shoes"

/obj/item/clothing/head/helmet/space/rig/security
	name = "hood"


/decl/hierarchy/supply_pack/security/rig
	name = "Armor - Security rig"
	contains = list(/obj/item/weapon/rig/security)
	cost = 120
	containername = "\improper Security rig crate"
	containertype = /obj/structure/closet/crate/secure/large
	access = access_security
