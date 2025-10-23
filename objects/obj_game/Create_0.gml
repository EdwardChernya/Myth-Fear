/// @description Insert description here
// You can write your code in this editor

#macro VERSION "fix3_8dev"
global.dev = false;
#macro DEV global.dev
global.gamespeed = 1;
game_set_speed(60, gamespeed_fps);

global.game_paused = false;
#macro PAUSED global.game_paused

instance_create_layer(0, 0, "Instances", obj_player);
instance_create_layer(0, 0, "Instances", obj_camera);
instance_create_layer(0, 0, "Map", obj_map);

global.character_main = obj_player.character_main;
#macro PLAYER global.character_main
#macro MAP obj_map
#macro CAMERA obj_camera
#macro TILE 64

global.part_system = new particle_system();
#macro PARTICLE_SYSTEM global.part_system
global.part_intensity = 1;
#macro PARTICLE_INTENSITY global.part_intensity

global.mouse_input = {
	x : 1,
	y : 1,
};
#macro MOUSE global.mouse_input


button_text = "generate map";

global.debug_text = new floating_text_manager();
#macro DEBUG global.debug_text

// other stuff
#macro IN_COMBAT 300 // 5 seconds since last hit/damage dealt


// browser stuff
if (webgl_enabled) {
	DEBUG.add("webgl enabled", c_olive);
} else { DEBUG.add("webgl error", c_red); }
if (os_browser != browser_not_a_browser) {
	var browser;
	switch (os_browser) {
		case browser_unknown 	    : browser = "Unknown browser"; 
			break;
		case browser_ie 	        : browser = "Internet Explorer"; 
			break;
		case browser_ie_mobile 	    : browser = "Internet Explorer on a mobile device"; 
			break;
		case browser_edge 	        : browser = "Microsoft Edge"; 
			break;
		case browser_firefox 	    : browser = "Mozilla Firefox"; 
			break;
		case browser_chrome 	    : browser = "Google Chrome"; 
			break;
		case browser_safari 	    : browser = "Safari"; 
			break;
		case browser_safari_mobile 	: browser = "Safari on a mobile device"; 
			break;
		case browser_opera      	: browser = "Opera"; 
			break;
		case browser_tizen 	        : browser = "Tizen mobile device browser"; 
			break;
		case browser_windows_store  : browser = "Windows App"; 
			break;
	}
	DEBUG.add($"{browser}", c_olive);
} else {
	DEBUG.add($"running outside of browser", c_red);
}

