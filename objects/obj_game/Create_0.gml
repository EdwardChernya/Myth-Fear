/// @description Insert description here
// You can write your code in this editor

#macro VERSION "7dev"
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


if (os_browser != browser_not_a_browser && !instance_exists(obj_HTML_FS)) { instance_create_depth(x,y,depth,obj_HTML_FS); }
button_text = "generate map";

global.debug_text = new floating_text_manager();
#macro DEBUG global.debug_text

// other stuff
#macro IN_COMBAT 300 // 5 seconds since last hit/damage dealt


DEBUG.add("game started", c_olive);


