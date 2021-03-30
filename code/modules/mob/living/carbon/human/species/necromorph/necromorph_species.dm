/*
	Base species for necromorphs,. the reanimated organic assemblages of the Dead Space universe

	This datum should probably not be used as is, but instead make variants of it for each type of necromorph
*/

/datum/species/necromorph
	name = "Necromorph"
	name_plural =  "Necromorphs"
	blurb = "Mutated and reanimated corpses, reshaped into horrific new forms by a recombinant extraterrestrial infection. \
	The resulting creatures are extremely aggressive and will attack any uninfected organism on sight."

	//Spawning and biomass
	var/marker_spawnable = TRUE	//Set this to true to allow the marker to spawn this type of necro. Be sure to unset it on the enhanced version unless desired
	var/preference_settable = TRUE
	biomass = 80	//This var is defined for all species
	var/require_total_biomass = 0	//If set, this can only be spawned when total biomass is above this value
	var/biomass_reclamation	=	1	//The marker recovers cost*reclamation
	var/biomass_reclamation_time	=	8 MINUTES	//How long does it take for all of the reclaimed biomass to return to the marker? This is a pseudo respawn timer
	var/spawn_method = SPAWN_POINT	//What method of spawning from marker should be used? At a point or manual placement? check _defines/necromorph.dm
	var/major_vessel = TRUE	//If true, we can fill this mob from the necroqueue
	var/spawner_spawnable = FALSE	//If true, a nest can be upgraded to autospawn this unit
	var/necroshop_item_type = /datum/necroshop_item //Give this a subtype if you want to have special behaviour for when this necromorph is spawned from the necroshop
	var/global_limit = 0	//0 = no limit
	lasting_damage_factor = 0.2	//Necromorphs take lasting damage based on incoming hits

	strength    = STR_MEDIUM
	show_ssd = "dead" //If its not moving, it looks like a corpse
	hunger_factor = 0 // Necros don't eat
	taste_sensitivity = 0      // no eat
	virus_immune = 1 // immune to viruses


	death_message = ""
	knockout_message = "crumples into a heap"
	halloss_message = "twitches and collapses"
	halloss_message_self = "your limbs spasm violently, pitching you forward onto the ground"



	//Vision
	darksight_range = -1
	darksight_tint = DARKTINT_MODERATE

	//Sprites
	damage_overlays = null
	damage_mask = null
	lying_rotation = 0

	//Single iconstates. These are somewhat of a hack
	var/single_icon = TRUE
	icon_template = 'icons/mob/necromorph/48x48necros.dmi'
	var/icon_normal = "slasher_d"
	icon_lying = "slasher_d_lying"
	var/icon_dead = "slasher_d_dead"

	//Icon details. null out all of these, maybe someday they can be done
	deform 			=   null
	preview_icon 	= 	null
	husk_icon 		=   null
	damage_overlays =   null
	damage_mask 	=   null
	blood_mask 		=   null

	/*
		Necromorph customisation system
	*/
	var/list/variants			//Species variants included. This is an assoc list in the format: species_name = list(weight, patron)
		//If patron is true, this variant is not available by default
	var/list/outfits = list(null = 1)		//Outfits the mob can spawn with, weighted. Null outfit is for naked
	//var/naked_chance = 40	//If outfits are available, chance to not spawn with one

	//Biology
	blood_color = COLOR_BLOOD_NECRO
	can_vomit = FALSE

	//Defense
	total_health = 80
	healing_factor = 0	//Necromorphs don't naturally heal, but they will be able to heal through certain situational effects
	limb_health_factor = 0.60	//Limbs easier to cut off
	wound_remnant_time = 0 //No cuts sitting around forever
	burn_mod = 1.3	//Takes more damage from burn attacks
	weaken_mod = 0.75	//Get back up faster
	blood_oxy = FALSE
	reagent_tag = IS_NECROMORPH
	stability = 0.8
	max_heal_threshold	=	1	//The few necros who can regenerate, are not constrained by wound size

	var/list/initial_health_values	//This list is populated once for each species, when a necromorph of that type is created
	//It stores the starting max health values of each limb this necromorph has
	//It is an associative list in the format organ_tag = initial health

	var/torso_damage_mult	=	0.25
	/*
		For the purpose of determining whether or not the necromorph has taken enough damage to be killed:
			Damage to the chest and groin is treated as being multiplied by this,
	*/

	var/dismember_mult = 1.2
	/*
		For the purpose of determining whether or not the necromorph has taken enough damage to be killed:
			A limb which is completely severed counts as its max damage multiplied by this
	*/


	//Breathing and Environment
	warning_low_pressure = 0             // Low pressure warning.
	hazard_low_pressure = 0               // Dangerously low pressure.

	breath_pressure = 0 // does not breathe
	oxy_mod =        0 //No breathing, no suffocation

	//Far better cold tolerance than humans
	body_temperature = null //No thermoregulation, will be the same temp as the environment around it
	cold_level_1 = 200                                      // Cold damage level 1 below this point. -30 Celsium degrees
	cold_level_2 = 140                                      // Cold damage level 2 below this point.
	cold_level_3 = 100                                      // Cold damage level 3 below this point.

	cold_discomfort_level = 220                             // Aesthetic messages about feeling chilly.



	//Interaction
	has_fine_manipulation = FALSE //Can't use most objects
	can_pickup = FALSE	//Can't pickup objects
	species_flags = SPECIES_FLAG_NO_PAIN | SPECIES_FLAG_NO_MINOR_CUT | SPECIES_FLAG_NO_POISON  | SPECIES_FLAG_NO_BLOCK      // Various specific features.
	appearance_flags = 0      // Appearance/display related features.
	spawn_flags = SPECIES_IS_RESTRICTED | SPECIES_NO_FBP_CONSTRUCTION | SPECIES_NO_FBP_CHARGEN           // Flags that specify who can spawn as this specie
	language = LANGUAGE_NECROCHAT

	//Audio
	step_volume = 60 //Necromorphs can't wear shoes, so their base footstep volumes are louder
	step_range = 1
	pain_audio_threshold = 0.10
	speech_chance = 100


	has_organ = list(    // which required-organ checks are conducted.
	BP_HEART =    /obj/item/organ/internal/heart/undead,
	BP_LUNGS =    /obj/item/organ/internal/lungs/undead,
	BP_LIVER =    /obj/item/organ/internal/liver/undead,
	BP_KIDNEYS =  /obj/item/organ/internal/kidneys/undead,
	BP_BRAIN =    /obj/item/organ/internal/brain/undead,
	BP_EYES =     /obj/item/organ/internal/eyes
	)

	locomotion_limbs = list(BP_L_LEG, BP_R_LEG)

	has_limbs = list(
	BP_CHEST =  list("path" = /obj/item/organ/external/chest/simple, "height" = new /vector2(1,1.65)),
	BP_HEAD =   list("path" = /obj/item/organ/external/head/simple, "height" = new /vector2(1.65,1.85)),
	BP_L_ARM =  list("path" = /obj/item/organ/external/arm/simple, "height" = new /vector2(0.8,1.60)),
	BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right/simple, "height" = new /vector2(0.8,1.60)),
	BP_L_LEG =  list("path" = /obj/item/organ/external/leg/simple, "height" = new /vector2(0,1)),
	BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right/simple, "height" = new /vector2(0,1))
	)

	defensive_limbs = list(UPPERBODY = list(BP_L_ARM, BP_R_ARM), //Arms and hands are used to shield the face and body
	LOWERBODY = list(BP_L_LEG, BP_R_LEG))


	//Necromorphs can't grab people or pick things up unless otherwise noted
	grasping_limbs = list()

	organ_substitutions = list(BP_L_HAND = BP_L_ARM,
	BP_R_HAND = BP_R_ARM,
	BP_L_FOOT = BP_L_LEG,
	BP_R_FOOT = BP_R_LEG)

	//HUD Handling
	hud_type = /datum/hud_data/necromorph

/datum/species/necromorph/psychosis_vulnerable()
	return FALSE

/datum/species/necromorph/New()
	.=..()
	breathing_organ = null //This is autoset to lungs in the parent if they exist.
	//We want it to be unset but we stil want to have our useless lungs


/datum/species/necromorph/get_blood_name()
	return "ichor"

/datum/species/necromorph/get_icobase(var/mob/living/carbon/human/H)
	return icon_template //We don't need to duplicate the same dmi path twice

/datum/species/necromorph/add_inherent_verbs(var/mob/living/carbon/human/H)
	.=..()
	H.verbs |= /mob/proc/necro_evacuate	//Add the verb to vacate the body. its really just a copy of ghost
	H.verbs |= /mob/proc/prey_sightings //Verb to see the sighting information on humans
	H.verbs |= /datum/proc/help //Verb to see your own abilities
	//H.verbs |= /mob/proc/message_unitologists
	make_scary(H)

/datum/species/necromorph/proc/make_scary(mob/living/carbon/human/H)
	//H.set_traumatic_sight(TRUE) //All necrmorphs are scary. Some are more scary than others though

/datum/species/necromorph/setup_interaction(var/mob/living/carbon/human/H)
	.=..()
	H.a_intent = I_HURT	//Don't start in help intent, we want to kill things
	H.faction = FACTION_NECROMORPH

//Add this necro as a vision node for the marker and signals
/datum/species/necromorph/setup_interaction(var/mob/living/carbon/human/H)
	.=..()
	GLOB.necrovision.add_source(H)


//We don't want to be suffering for the lack of most particular organs
/datum/species/necromorph/should_have_organ(var/query)
	if (query in list(BP_EYES))	//Expand this list as needed
		return ..()
	return FALSE


//Populate the initial health values
/datum/species/necromorph/create_organs(var/mob/living/carbon/human/H)
	.=..()
	if (!initial_health_values)
		initial_health_values = list()
		for (var/organ_tag in H.organs_by_name)
			var/obj/item/organ/external/E	= H.organs_by_name[organ_tag]
			initial_health_values[organ_tag] = E.max_damage

	if (biomass)
		add_massive_atom(H)


//Necromorphs die when they've taken enough total damage to all their limbs.
/datum/species/necromorph/handle_death_check(var/mob/living/carbon/human/H)

	var/damage = get_weighted_total_limb_damage(H)
	if (damage >= H.max_health)
		return TRUE

	return FALSE


/datum/species/necromorph/handle_death(var/mob/living/carbon/human/H)
	//We just died? Lets start getting absorbed by the marker
	if (!SSnecromorph.marker)	//Gotta have one
		return
	if (H.biomass)
		SSnecromorph.marker.add_biomass_source(H, H.biomass*biomass_reclamation, biomass_reclamation_time, /datum/biomass_source/reclaim)
		remove_massive_atom(H)
	GLOB.necrovision.remove_source(H)

//How much damage has this necromorph taken?
//We'll loop through each organ tag in the species' initial health values list, which should definitely be populated already, and try to get the organ for each
	//Any limb still attached, adds its current damage to the total
	//Any limb no longer attached (or stumped) adds its pre-cached max damage * dismemberment mult to the total
	//Any limb which is considered to be a torso part adds its damage, multiplied by the torso mult, to the total
	//The return list var is used for hud healthbars
/datum/species/necromorph/proc/get_weighted_total_limb_damage(var/mob/living/carbon/human/H, var/return_list)
	var/total = 0
	var/blocked = 0
	if (!initial_health_values)
		return 0 //Not populated? welp

	for (var/organ_tag in initial_health_values)
		var/obj/item/organ/external/E	= H.organs_by_name[organ_tag]
		var/subtotal = 0
		if (!E || E.is_stump())
			//Its not here!

			subtotal = initial_health_values[organ_tag] * dismember_mult
			blocked += subtotal
		else
			//Its here
			subtotal = E.damage

			//Is it a torso part?
			if ((E.organ_tag in BP_TORSO))
				subtotal *= torso_damage_mult


		//And now add to total
		total += subtotal

	var/lasting = H.getLastingDamage()
	blocked += lasting
	total += lasting

	if (return_list)
		return list("damage" = total, "blocked" = blocked)

	return total

//Individual necromorphs are identified only by their species
/datum/species/necromorph/get_random_name()
	return "[src.name] [rand(0,999)]"

// Used to update alien icons for aliens.
/datum/species/necromorph/handle_login_special(var/mob/living/carbon/human/H)
	.=..()
	H.set_necromorph(TRUE)
	to_chat(H, "You are a [name]. \n\
	[blurb]\n\
	\n\
	Check the Abilities tab, use the Help ability to find out what your controls and abilities do!")



/datum/species/necromorph/can_autoheal(var/mob/living/carbon/human/H, var/dam_type, var/datum/wound/W)
	if (healing_factor > 0)
		return TRUE
	else
		return FALSE



/*
	Return true if this species has any customisation options at all
*/
/datum/species/necromorph/proc/has_customisation()

	//This is how we mark variant subtypes
	if (preference_settable == FALSE)
		return FALSE

	if (variants)
		return TRUE

	return FALSE

/*
	This produces all the content for the customisation menu main panel, when this species is selected
*/
/datum/species/necromorph/proc/get_customisation_content(var/datum/preferences/prefs, var/mob/living/user)
	. += "<table>"
	var/list/data = LAZYACCESS(prefs.necro_custom, name)	//This gets the list containing all saved customisation data for this necromorph category
	if (!data)	data = list()

	if (variants)
		.+= "<tr><td>"
		.+= "<h1>Variants</h1>"

		//This gets the sublist containing all saved customisation data for this subcategory
		var/list/variants_data = LAZYACCESS(data, VARIANT)
		if (!variants_data)	variants_data = list()

		for (var/species_name in variants)
			var/datum/species/necromorph/S = GLOB.all_necromorph_species[species_name]
			var/is_enabled = (species_name in variants_data)
			. += image_check_panel(text = species_name, I = S.get_default_icon(), ticked = is_enabled, user = user, command = is_enabled ? "disable" : "enable", source = src, category = src.name, subcategory = VARIANT)
		. += "</td></tr>"


/datum/species/necromorph/proc/prefill_customisation_prefs(var/datum/preferences/prefs)
	prefs.necro_custom[name] = list()
	if (variants)
		var/list/public_variants = list()
		for (var/vname in variants)
			var/list/params = variants[vname]

			//Premium variant, not implemented by default
			if (params[PATRON])
				continue
		prefs.necro_custom[name][VARIANT]	=	variants.Copy()

/datum/species/necromorph/proc/get_default_icon()
	if (!default_icon)
		var/mob/living/carbon/human/H = new mob_type(locate(1,1,1), src.name)	//Create a new human of our species
		default_icon = getFlatIcon(H)

	return default_icon
