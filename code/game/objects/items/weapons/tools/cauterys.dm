/obj/item/weapon/tool/cautery
	name = "cautery"
	desc = "This cauterises and closes incisions."
	icon_state = "cautery"
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 200)
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("burnt")
	tool_qualities = list(QUALITY_CAUTERIZING = 30)
