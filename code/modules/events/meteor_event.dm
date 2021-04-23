#define FRONTAL_METEOR_SPREAD	35

/datum/event/meteor_wave
	startWhen		= 30	// About one minute early warning
	endWhen 		= 60	// Adjusted automatically in tick()
	var/alarmWhen   = 30
	var/next_meteor = 40
	var/waves = 1
	var/start_side
	var/next_meteor_lower = 10
	var/next_meteor_upper = 20


/datum/event/meteor_wave/setup()
	waves = 0
	for(var/n in 1 to severity)
		waves += rand(5,15)
	var/obj/structure/asteroidcannon/AC = GLOB.asteroid_cannon
	start_side = AC.dir //Again, so they have a chance to shoot them down.
	endWhen = worst_case_end()

/datum/event/meteor_wave/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce(replacetext(GLOB.using_map.meteor_detected_message, "%STATION_NAME%", location_name()), "[location_name()] Sensor Array", new_sound = GLOB.using_map.meteor_detected_sound, zlevels = affecting_z)
		else
			command_announcement.Announce("The [location_name()] is now in a meteor shower.", "[location_name()] Sensor Array", zlevels = affecting_z)

/datum/event/meteor_wave/tick()
	// Begin sending the alarm signals to shield diffusers so the field is already regenerated (if it exists) by the time actual meteors start flying around.
	if(alarmWhen < activeFor)
		for(var/obj/machinery/shield_diffuser/SD in SSmachines.machinery)
			if(isStationLevel(SD.z))
				SD.meteor_alarm(10)

	if(waves && activeFor >= next_meteor)
		send_wave()

/datum/event/meteor_wave/proc/worst_case_end()
	return activeFor + ((30 / severity) * waves) + 30

/datum/event/meteor_wave/proc/send_wave()
	var/pick_side = prob(80) ? start_side : (prob(50) ? turn(start_side, 90) : turn(start_side, -90))
	spawn() spawn_meteors(get_wave_size(), get_meteors(), pick_side, pick(affecting_z))

/datum/event/meteor_wave/proc/get_wave_size()
	return severity * rand(2,3)

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce("The [location_name()] has cleared the meteor storm.", "[location_name()] Sensor Array", zlevels = affecting_z)
		else
			command_announcement.Announce("The [location_name()] has cleared the meteor shower", "[location_name()] Sensor Array", zlevels = affecting_z)

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return meteors_major
		if(EVENT_LEVEL_MODERATE)
			return meteors_moderate
		else
			return meteors_minor

/var/list/meteors_minor = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
)

/var/list/meteors_moderate = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	/obj/effect/meteor/emp        = 10,
)

/var/list/meteors_major = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/emp        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	///obj/effect/meteor/tunguska   = 1,	//This thing is too much
)

/datum/event/meteor_wave/overmap
	next_meteor_lower = 5
	next_meteor_upper = 10
	next_meteor = 0
	var/obj/effect/overmap/ship/victim

/datum/event/meteor_wave/overmap/Destroy()
	victim = null
	. = ..()

/datum/event/meteor_wave/overmap/tick()
	if(victim && !victim.is_still()) //Meteors mostly fly in your face
		start_side = prob(90) ? victim.fore_dir : pick(GLOB.cardinal)
	else //Unless you're standing
		start_side = pick(GLOB.cardinal)
	..()

/datum/event/meteor_wave/overmap/get_wave_size()
	. = ..()
	if(!victim)
		return
	if(victim.get_helm_skill() == SKILL_PROF)
		. = round(. * 0.5)
	if(victim.is_still()) //Standing still means less shit flies your way
		. = round(. * 0.25)
	if(victim.get_speed() < 0.3) //Slow and steady
		. = round(. * 0.6)
	if(victim.get_speed() > 3) //Sanic stahp
		. *= 2





/datum/event/meteor_wave/ishimura
	startWhen = 0
	next_meteor = 0
	start_side = EAST	//Meteors always come from the front


/datum/event/meteor_wave/ishimura/send_wave()
	var/obj/structure/asteroidcannon/AC = GLOB.asteroid_cannon
	spawn()
		spawn_meteors(get_wave_size(), get_meteors(), start_side, AC.z, frontal = TRUE) //Overrode this so meteors only spawn on the Z-level that the asteroid cannon is on.
	next_meteor += rand(next_meteor_lower, next_meteor_upper) / severity
	waves--
	endWhen = worst_case_end()





/proc/spaceDebrisFrontalStartLoc(startSide, Z)
	var/obj/structure/asteroidcannon/AC = GLOB.asteroid_cannon
	var/starty
	var/startx
	switch(startSide)	//TODO: Other sides
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand(AC.y + FRONTAL_METEOR_SPREAD,AC.y - FRONTAL_METEOR_SPREAD)
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand(AC.y + FRONTAL_METEOR_SPREAD,AC.y - FRONTAL_METEOR_SPREAD)
			startx = (TRANSITIONEDGE+1)
	var/turf/T = locate(startx, starty, Z)
	return T


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(var/number = 10, var/list/meteortypes, var/startSide, var/zlevel, var/frontal = FALSE)
	for(var/i = 0; i < number; i++)
		spawn_meteor(meteortypes, startSide, zlevel, frontal)

/proc/spawn_meteor(var/list/meteortypes, var/startSide, var/zlevel, var/frontal = FALSE)
	var/turf/pickedstart

	if (frontal)
		pickedstart = spaceDebrisFrontalStartLoc(startSide, zlevel)
	else
		pickedstart = spaceDebrisStartLoc(startSide, zlevel)
	var/turf/pickedgoal = spaceDebrisFinishLoc(startSide, zlevel)

	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart)
	M.start_side = startSide
	M.velocity = new /vector2()
	if(pickedgoal.x != pickedstart.x)
		M.velocity.x = (pickedgoal.x < pickedstart.x) ? -2 : 2
	if(pickedgoal.y != pickedstart.y)
		M.velocity.y = (pickedgoal.y < pickedstart.y) ? -2 : 2
	M.set_destination(pickedgoal)
	return

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	var/turf/T = locate(startx, starty, Z)
	return T

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(EAST)
			endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
			endx = TRANSITIONEDGE
		if(SOUTH)
			endy = world.maxy-TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(WEST)
			endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
			endx = world.maxx-TRANSITIONEDGE
	var/turf/T = locate(endx, endy, Z)
	return T