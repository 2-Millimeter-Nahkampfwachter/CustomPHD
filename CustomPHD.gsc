#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_powerups;

init(){
	thread why();
}

why()
{
	level waittill( "start_of_round" );
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