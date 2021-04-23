// SEE code/modules/materials/materials.dm FOR DETAILS ON INHERITED DATUM.
// This class of weapons takes force and appearance data from a material datum.
// They are also fragile based on material data and many can break/smash apart.
/obj/item/weapon/material
	health = 100
	hitsound = 'sound/weapons/bladeslice.ogg'
	gender = NEUTER

	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
	sharp = 0
	edge = 0

	var/applies_material_colour = 1
	var/unbreakable
	var/force_divisor = 0.5
	var/thrown_force_divisor = 0.5
	var/attack_cooldown_modifier
	var/default_material = MATERIAL_STEEL
	var/material/material
	var/drops_debris = 1

/obj/item/weapon/material/New(var/newloc, var/material_key)
	..(newloc)
	if(!material_key)
		material_key = default_material
	set_material(material_key)
	if(!material)
		qdel(src)
		return

	matter = material.get_matter()
	if(matter.len)
		for(var/material_type in matter)
			if(!isnull(matter[material_type]))
				matter[material_type] *= force_divisor // May require a new var instead.

/obj/item/weapon/material/get_material()
	return material

/obj/item/weapon/material/get_heat_limit()
	var/material/M = get_material()
	if (M)
		return M.get_heat_limit()

	.=..()

/obj/item/weapon/material/proc/update_force()
	if(edge || sharp)
		force = material.get_edge_damage()
	else
		force = material.get_blunt_damage()
	force = round(force*force_divisor)
	throwforce = round(material.get_blunt_damage()*thrown_force_divisor)
	attack_cooldown = material.get_attack_cooldown() + attack_cooldown_modifier

/obj/item/weapon/material/proc/set_material(var/new_material)
	material = get_material_by_name(new_material)
	if(!material)
		qdel(src)
	else
		SetName("[material.display_name] [initial(name)]")
		max_health = round(material.integrity)
		health = max_health
		if(applies_material_colour)
			color = material.icon_colour
		if(material.products_need_process())
			START_PROCESSING(SSobj, src)
		if(material.conductive)
			obj_flags |= OBJ_FLAG_CONDUCTIBLE
		else
			obj_flags &= (~OBJ_FLAG_CONDUCTIBLE)
		update_force()

/obj/item/weapon/material/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/material/zero_health()
	shatter()

/obj/item/weapon/material/proc/shatter(var/consumed)
	var/turf/T = get_turf(src)
	if (T)
		T.visible_message("<span class='danger'>\The [src] [material.destruction_desc]!</span>")
		playsound(src, "shatter", 70, 1)
		if(!consumed && drops_debris)
			material.place_shard(T)
	if (!QDELETED(src))
		qdel(src)
/*
Commenting this out pending rebalancing of radiation based on small objects.
/obj/item/weapon/material/process()
	if(!material.radioactivity)
		return
	for(var/mob/living/L in range(1,src))
		L.apply_effect(round(material.radioactivity/30),IRRADIATE, blocked = L.getarmor(null, "rad"))
*/

/*
// Commenting this out while fires are so spectacularly lethal, as I can't seem to get this balanced appropriately.
/obj/item/weapon/material/fire_act(var/datum/gas_mixture/air, var/exposed_temperature, var/exposed_volume, var/multiplier = 1)
	TemperatureAct(exposed_temperature)

// This might need adjustment. Will work that out later.
/obj/item/weapon/material/proc/TemperatureAct(temperature)
	health -= material.combustion_effect(get_turf(src), temperature, 0.1)
	check_health(1)

/obj/item/weapon/material/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/tool/weldingtool))
		var/obj/item/weapon/tool/weldingtool/WT = W
		if(material.ignition_point && WT.remove_fuel(0, user))
			TemperatureAct(150)
	else
		return ..()
*/
