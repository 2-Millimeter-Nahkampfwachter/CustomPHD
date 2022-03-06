#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_powerups;

init(){
	if(isDefined(level.player_damage_callbacks[0])){
		level.first_player_damage_callback = level.player_damage_callbacks[0];
		level.player_damage_callbacks[0] = ::playerdamagelastcheck;
	} else {
		maps/mp/zombies/_zm::register_player_damage_callback( ::playerdamagelastcheck );
	}
	if(isDefined(level._effect[ "divetonuke_groundhit" ])){
		level.phd_fx = level._effect[ "divetonuke_groundhit" ];
	} else {
		if(!isDefined(level._effect[ "def_explosion" ])){
			level.phd_fx = loadfx( "explosions/fx_default_explosion" );
		} else {
			level.phd_fx = level._effect[ "def_explosion" ];
		}
	}

	level.required_kills_for_phd = 100;
	level.callbackactorkilledoriginal = level.callbackactorkilled;
	level.callbackactorkilled = ::onkilled;
	level thread onplayerconnect();
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	level endon( "game_ended" );
    self endon( "disconnect" );
	for(;;)
	{
		self iPrintLn(level.required_kills_for_phd);
		self.killcount = 0;
		self.has_phd = 0;
		self waittill( "spawned_player" );
	}
}

playerdamagelastcheck( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ){
	if(isDefined(self.has_phd) && self.has_phd){
		if( smeansofdeath == "MOD_FALLING" ){
			if(isDefined( self.divetoprone ) && self.divetoprone == 1 ){
				if(self is_insta_kill_active()){
					radiusdamage( self.origin, 300, level.zombie_health + 69, level.zombie_health + 69, self, "MOD_GRENADE_SPLASH" );
				}
				radiusdamage( self.origin, 300, 5000, 1000, self, "MOD_GRENADE_SPLASH" );
				playfx(level.phd_fx, self.origin, anglestoforward( ( 0, 45, 55  ) ) ); 
				self playsound( "zmb_phdflop_explo" );
			}
			return 0;
		}
		if(smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || eattacker == self && !smeansofdeath == "MOD_UNKNOWN"){
			return 0;
		}
	}
	if(isDefined(level.first_player_damage_callback)){
		return [[level.first_player_damage_callback]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime);
	}
	return idamage;
}

onkilled(einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime){
	if(isDefined( attacker ) && isplayer( attacker )){
		attacker.killcount++;
		if(attacker.killcount >= level.required_kills_for_phd && attacker.has_phd == 0){
			attacker.has_phd = 1;
			attacker iPrintLn("^1" + attacker.name + " now has PHD");
		}
	}
	[[level.callbackactorkilledoriginal]](einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime);
}