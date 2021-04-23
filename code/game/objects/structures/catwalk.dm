/obj/structure/catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk"
	density = 0
	anchored = 1.0
	var/obj/item/stack/tile/mono/plated_tile
	plane = ABOVE_TURF_PLANE
	layer = CATWALK_LAYER
	var/hatch_open = FALSE
	footstep_sounds= list(
		'sound/effects/footstep/catwalk1.ogg',
		'sound/effects/footstep/catwalk2.ogg',
		'sound/effects/footstep/catwalk3.ogg',
		'sound/effects/footstep/catwalk4.ogg',
		'sound/effects/footstep/catwalk5.ogg')

	can_block_movement = FALSE //It IS the floor
	atom_flags = ATOM_FLAG_UNTARGETABLE

/obj/structure/catwalk/register_zstructure(var/turf/T)
	LAZYSET(T.zstructures, src, 1)	//Ladders have a ztransition priority of 2 to overrule other things

/obj/structure/catwalk/Initialize()
	. = ..()
	for(var/obj/structure/catwalk/C in get_turf(src))
		if(C != src)
			qdel(C)
	var/turf/T = get_turf(src)
	register_zstructure(T)
	update_connections(1)
	update_icon()

/obj/structure/catwalk/Destroy()

	unregister_zstructure(get_turf(src))
	.=..()

/obj/structure/catwalk/CanZPass(atom/A, direction)
	if(z == A.z)
		if(direction == DOWN)
			return FALSE
	else if(direction == UP)
		return FALSE
	return ZTRANSITION_MAYBE

/obj/structure/catwalk/Destroy()
	redraw_nearby_catwalks()
	return ..()

/obj/structure/catwalk/proc/redraw_nearby_catwalks()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/catwalk/L = locate() in get_step(src, direction)
		if(L)
			L.update_connections()
			L.update_icon() //so siding get updated properly


/obj/structure/catwalk/update_icon()
	update_connections()
	overlays.Cut()
	icon_state = ""
	var/image/I
	if(!hatch_open)
		for(var/i = 1 to 4)
			I = image('icons/obj/catwalks.dmi', "catwalk[connections[i]]", dir = 1<<(i-1))
			overlays += I
	if(plated_tile)
		I = image('icons/obj/catwalks.dmi', "plated")
		I.color = plated_tile.color
		overlays += I



/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/stack/rods(src.loc)
			qdel(src)
		if(2)
			new /obj/item/stack/rods(src.loc)
			qdel(src)

/obj/structure/catwalk/attack_hand(mob/user)
	if(user.pulling)
		do_pull_click(user, src)
	..()

/obj/structure/catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(isWelder(C))
		to_chat(user, "<span class='notice'>Slicing \the [src] joints ...</span>")
		if (C.use_tool(user, src, WORKTIME_SLOW, QUALITY_WELDING, FAILCHANCE_NORMAL))
			new /obj/item/stack/rods(src.loc)
			new /obj/item/stack/rods(src.loc)
			//Lattice would delete itself, but let's save ourselves a new obj
			if(istype(src.loc, /turf/space) || istype(src.loc, /turf/simulated/open))
				new /obj/structure/lattice/(src.loc)
			if(plated_tile)
				new plated_tile.build_type(src.loc)
			qdel(src)
		return
	if(isCrowbar(C) && plated_tile && C.use_tool(user, src, WORKTIME_FAST, QUALITY_PRYING, FAILCHANCE_NORMAL))
		hatch_open = !hatch_open
		if(hatch_open)
			playsound(src, 'sound/items/Crowbar.ogg', 100, 2)
			to_chat(user, "<span class='notice'>You pry open \the [src]'s maintenance hatch.</span>")
		else
			playsound(src, 'sound/items/Deconstruct.ogg', 100, 2)
			to_chat(user, "<span class='notice'>You shut \the [src]'s maintenance hatch.</span>")
		update_icon()
		return
	if(istype(C, /obj/item/stack/tile/mono) && !plated_tile)
		var/obj/item/stack/tile/floor/ST = C
		if(!ST.in_use)
			to_chat(user, "<span class='notice'>Placing tile...</span>")
			ST.in_use = 1
			if (!do_after(user, 10))
				ST.in_use = 0
				return
			to_chat(user, "<span class='notice'>You plate \the [src]</span>")
			name = "plated catwalk"
			ST.in_use = 0
			src.add_fingerprint(user)
			if(ST.use(1))
				for(var/flooring_type in flooring_types)
					var/decl/flooring/F = flooring_types[flooring_type]
					if(!F.build_type)
						continue
					if(ispath(C.type, F.build_type))
						plated_tile = F
						break
				update_icon()

/obj/effect/catwalk_plated
	name = "plated catwalk spawner"
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk_plated"
	density = 1
	anchored = 1.0
	var/activated = FALSE
	layer = ABOVE_TURF_PLANE
	var/plating_type = /decl/flooring/tiling/mono

/obj/effect/catwalk_plated/Initialize(mapload)
	. = ..()
	var/auto_activate = mapload || (ticker && ticker.current_state < GAME_STATE_PLAYING)
	if(auto_activate)
		activate()
		return INITIALIZE_HINT_QDEL

/obj/effect/catwalk_plated/CanPass()
	return 0

/obj/effect/catwalk_plated/attack_hand()
	attack_generic()

/obj/effect/catwalk_plated/attack_ghost()
	attack_generic()

/obj/effect/catwalk_plated/attack_generic()
	activate()

/obj/effect/catwalk_plated/proc/activate()
	if(activated) return

	if(locate(/obj/structure/catwalk) in loc)
		warning("Frame Spawner: A catwalk already exists at [loc.x]-[loc.y]-[loc.z]")
	else
		var/obj/structure/catwalk/C = new /obj/structure/catwalk(loc)
		C.plated_tile += new plating_type
		C.name = "plated catwalk"
		C.update_icon()
	activated = 1
	for(var/turf/T in orange(src, 1))
		for(var/obj/effect/wallframe_spawn/other in T)
			if(!other.activated) other.activate()

/obj/effect/catwalk_plated/dark
	icon_state = "catwalk_plateddark"
	plating_type = /decl/flooring/tiling/mono/dark

/obj/effect/catwalk_plated/white
	icon_state = "catwalk_platedwhite"
	plating_type = /decl/flooring/tiling/mono/white

//ds13 variants

/obj/effect/catwalk_plated/dank
	icon_state = "catwalk_platedgrim"
	plating_type = /decl/flooring/tiling/mono/dark




/*
	Rail for trams/monorail system
*/
/obj/structure/catwalk/rail
	name = "rail"
	plane = BELOW_TURF_PLANE
	simulated = FALSE	//This prevents it from being moved with the tram